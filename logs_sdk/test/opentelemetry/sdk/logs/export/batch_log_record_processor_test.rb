# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor do
  let(:exporter) { OpenTelemetry::SDK::Logs::Export::LogRecordExporter.new }
  let(:processor) { OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter) }
  let(:sampled_span_context) { OpenTelemetry::Trace::SpanContext.new(trace_flags: OpenTelemetry::Trace::TraceFlags::SAMPLED) }
  let(:log_record) { OpenTelemetry::SDK::Logs::LogRecord.new(span_context: sampled_span_context) }
  let(:mock_context) { Minitest::Mock.new }

  describe '#initialize' do
    it 'raises an error when exporter is invalid' do
      OpenTelemetry::Common::Utilities.stub(:valid_exporter?, false) do
        assert_raises(ArgumentError) { OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter) }
      end
    end

    it 'raises an error when exporter is nil' do
      OpenTelemetry::Common::Utilities.stub(:valid_exporter?, false) do
        assert_raises(ArgumentError) { OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(nil) }
      end
    end

    it 'raises if max_export_batch_size is greater than max_queue_size' do
      assert_raises ArgumentError do
        OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter, max_queue_size: 6, max_export_batch_size: 999)
      end
    end

    it 'raises if OTEL_BLRP_EXPORT_TIMEOUT env var is not numeric' do
      assert_raises ArgumentError do
        OpenTelemetry::TestHelpers.with_env('OTEL_BLRP_EXPORT_TIMEOUT' => 'foo') do
          OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter)
        end
      end
    end

    it 'sets parameters from the environment' do
      processor = OpenTelemetry::TestHelpers.with_env('OTEL_BLRP_EXPORT_TIMEOUT' => '4',
                                                      'OTEL_BLRP_SCHEDULE_DELAY' => '3',
                                                      'OTEL_BLRP_MAX_QUEUE_SIZE' => '2',
                                                      'OTEL_BLRP_MAX_EXPORT_BATCH_SIZE' => '1') do
        OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter)
      end

      assert_equal(0.004, processor.instance_variable_get(:@exporter_timeout_seconds))
      assert_equal(0.003, processor.instance_variable_get(:@delay_seconds))
      assert_equal(2, processor.instance_variable_get(:@max_queue_size))
      assert_equal(1, processor.instance_variable_get(:@batch_size))
    end

    it 'prefers explicit parameters rather than the environment' do
      processor = OpenTelemetry::TestHelpers.with_env('OTEL_BLRP_EXPORT_TIMEOUT' => '4',
                                                      'OTEL_BLRP_SCHEDULE_DELAY' => '3',
                                                      'OTEL_BLRP_MAX_QUEUE_SIZE' => '2',
                                                      'OTEL_BLRP_MAX_EXPORT_BATCH_SIZE' => '1') do
        OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter,
                                                                      exporter_timeout: 10,
                                                                      schedule_delay: 9,
                                                                      max_queue_size: 8,
                                                                      max_export_batch_size: 7)
      end

      assert_equal(0.01, processor.instance_variable_get(:@exporter_timeout_seconds))
      assert_equal(0.009, processor.instance_variable_get(:@delay_seconds))
      assert_equal(8, processor.instance_variable_get(:@max_queue_size))
      assert_equal(7, processor.instance_variable_get(:@batch_size))
    end

    it 'sets defaults for parameters not in the environment' do
      processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter)
      assert_equal(30.0, processor.instance_variable_get(:@exporter_timeout_seconds))
      assert_equal(1.0, processor.instance_variable_get(:@delay_seconds))
      assert_equal(2048, processor.instance_variable_get(:@max_queue_size))
      assert_equal(512, processor.instance_variable_get(:@batch_size))
    end

    it 'spawns a thread on boot by default' do
      mock = Minitest::Mock.new
      mock.expect(:call, nil)

      Thread.stub(:new, mock) do
        OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter)
      end

      mock.verify
    end

    it 'spawns a thread on boot if OTEL_RUBY_BLRP_START_THREAD_ON_BOOT is true' do
      mock = Minitest::Mock.new
      mock.expect(:call, nil)

      Thread.stub(:new, mock) do
        OpenTelemetry::TestHelpers.with_env('OTEL_RUBY_BLRP_START_THREAD_ON_BOOT' => 'true') do
          OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter)
        end
      end

      mock.verify
    end

    it 'does not spawn a thread on boot if OTEL_RUBY_BLRP_START_THREAD_ON_BOOT is false' do
      mock = Minitest::Mock.new
      mock.expect(:call, nil) { assert false }

      Thread.stub(:new, mock) do
        OpenTelemetry::TestHelpers.with_env('OTEL_RUBY_BLRP_START_THREAD_ON_BOOT' => 'false') do
          OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter)
        end
      end
    end

    it 'prefers explicit start_thread_on_boot parameter rather than the environment' do
      mock = Minitest::Mock.new
      mock.expect(:call, nil) { assert false }

      Thread.stub(:new, mock) do
        OpenTelemetry::TestHelpers.with_env('OTEL_RUBY_BLRP_START_THREAD_ON_BOOT' => 'true') do
          OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter,
                                                                        start_thread_on_boot: false)
        end
      end
    end
  end

  describe '#emit' do
    let(:sampled_span_context) { OpenTelemetry::Trace::SpanContext.new(trace_flags: OpenTelemetry::Trace::TraceFlags::SAMPLED) }
    let(:log_record) { OpenTelemetry::SDK::Logs::LogRecord.new(span_context: sampled_span_context) }

    it 'does not add the log record if it is not sampled' do
      # SpanContext's default trace_flags are not sampled
      log_record.instance_variable_set(:@span_context, OpenTelemetry::Trace::SpanContext.new)
      refute(log_record.span_context.trace_flags.sampled?)
      processor.emit(log_record, mock_context)

      refute_includes(processor.instance_variable_get(:@log_records), log_record)
    end

    it 'adds the log record to the batch' do
      processor.emit(log_record, mock_context)

      assert_includes(processor.instance_variable_get(:@log_records), log_record)
    end

    it 'removes the older log records from the batch if full' do
      processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter, max_queue_size: 1, max_export_batch_size: 1)

      older_log_record = OpenTelemetry::SDK::Logs::LogRecord.new(span_context: sampled_span_context)
      newer_log_record = OpenTelemetry::SDK::Logs::LogRecord.new(span_context: sampled_span_context)

      processor.emit(older_log_record, mock_context)
      processor.emit(newer_log_record, mock_context)

      records = processor.instance_variable_get(:@log_records)
      assert_includes(records, newer_log_record)
      refute_includes(records, older_log_record)
    end

    it 'logs a warning if a log record was emitted after the buffer is full' do
      logger_mock = Minitest::Mock.new
      logger_mock.expect(:warn, nil, [/buffer-full/])

      OpenTelemetry.stub(:logger, logger_mock) do
        processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter, max_queue_size: 1, max_export_batch_size: 1)

        log_record2 = OpenTelemetry::SDK::Logs::LogRecord.new(span_context: sampled_span_context)

        processor.emit(log_record, mock_context)
        processor.emit(log_record2, mock_context)
      end

      logger_mock.verify
    end

    # it 'signals the condition if log_records is larger than the batch_size' do
    #   processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(exporter, max_queue_size: 1, max_export_batch_size: 1)

    #   mock_condition = Minitest::Mock.new
    #   100_000.times do
    #     mock_condition.expect(:wait, nil, [processor.instance_variable_get(:@mutex), processor.instance_variable_get(:@delay_seconds)])
    #   end
    #   mock_condition.expect(:signal, nil)

    #   processor.instance_variable_set(:@condition, mock_condition)
    #   processor.instance_variable_get(:@log_records).stub(:size, 2) do
    #     processor.emit(log_record, mock_context)
    #   end

    #   mock_condition.verify
    # end

    # it 'does not add to the batch if keep_running is false' do
    #   processor.instance_variable_set(:@keep_running, false)

    #   processor.emit(log_record, mock_context)
    #   refute_includes(processor.instance_variable_get(:@log_records), log_record)
    # end

    # it 'does not export if log_record is nil' do
    #   # raise if export is invoked
    #   exporter.stub(:export, ->(_) { raise 'whoops!' }) do
    #     processor.emit(nil, mock_context)
    #   end
    # end

    # it 'does not raise if exporter is nil' do
    #   processor.instance_variable_set(:@log_record_exporter, nil)
    #   processor.emit(log_record, mock_context)
    # end

    # it 'does not export unless sampled' do
    #   # SpanContext's default trace_flags are not sampled
    #   log_record.instance_variable_set(:@span_context, OpenTelemetry::Trace::SpanContext.new)
    #   refute(log_record.span_context.trace_flags.sampled?)
    #   # raise if exporter's emit call is invoked
    #   exporter.stub(:export, ->(_) { raise 'whoops!' }) do
    #     processor.emit(log_record, mock_context)
    #   end
    # end

    # it 'catches and logs exporter errors' do
    #   error_message = 'uh oh'
    #   log_record.span_context = sampled_span_context
    #   logger_mock = Minitest::Mock.new
    #   logger_mock.expect(:error, nil, [/#{error_message}/])
    #   # raise if exporter's emit call is invoked
    #   OpenTelemetry.stub(:logger, logger_mock) do
    #     exporter.stub(:export, ->(_) { raise error_message }) do
    #       processor.emit(log_record, mock_context)
    #     end
    #   end

    #   logger_mock.verify
    # end
  end

  describe '#force_flush' do
    it 'reenqueues the remaining log records on timeout' do
      # raise if export is called, since the flush should timeout before export
      exporter.stub(:export, ->(_) { raise 'whoops!' }) do
        log_records = processor.instance_variable_get(:@log_records)
        log_record_array = [log_record, log_record]
        log_record_array.each { |r| processor.emit(r, mock_context) }

        assert_equal(2, log_records.size)
        assert_equal(OpenTelemetry::SDK::Logs::Export::TIMEOUT, processor.force_flush(timeout: 0))
        assert_equal(log_record_array, log_records)
      end
    end

    it 'exports the log record data and calls #force_flush on the exporter' do
      exporter = Minitest::Mock.new
      processor.instance_variable_set(:@exporter, exporter)
      log_record_data_mock = Minitest::Mock.new
      log_record.stub(:to_log_record_data, log_record_data_mock) do
        processor.emit(log_record, mock_context)
        exporter.expect(:export, 0, [[log_record_data_mock]], timeout: nil)
        exporter.expect(:force_flush, nil, timeout: nil)
        processor.force_flush
        exporter.verify
      end
    end

    it 'returns failure code if export_batch fails' do
      processor.stub(:export_batch, OpenTelemetry::SDK::Logs::Export::FAILURE) do
        processor.emit(log_record, mock_context)
        assert_equal(OpenTelemetry::SDK::Logs::Export::FAILURE, processor.force_flush)
      end
    end
  end

  describe '#shutdown' do
    it 'does not allow subsequent calls to emit after shutdown' do
      processor.shutdown
      processor.emit(log_record, mock_context)
      assert_empty(processor.instance_variable_get(:@log_records))
    end

    it 'does not send shutdown to exporter if already shutdown' do
      processor.instance_variable_set(:@stopped, true)

      exporter.stub(:shutdown, ->(_) { raise 'whoops!' }) do
        processor.shutdown
      end
    end

    it 'sets @stopped to true' do
      refute(processor.instance_variable_get(:@stopped))
      processor.shutdown
      assert(processor.instance_variable_get(:@stopped))
    end

    it 'calls force_flush and shutdown on the exporter' do
      exporter = Minitest::Mock.new
      processor.instance_variable_set(:@exporter, exporter)
      exporter.expect(:force_flush, nil, timeout: nil)
      exporter.expect(:shutdown, nil, timeout: nil)
      processor.shutdown
      exporter.verify
    end

    it 'respects the batch size' do
      mock_exporter = Minitest::Mock.new
      OpenTelemetry::Common::Utilities.stub(:valid_exporter?, true) do
        processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(mock_exporter, max_queue_size: 6, max_export_batch_size: 3)

        log_records = []
        4.times { log_records << OpenTelemetry::SDK::Logs::LogRecord.new(span_context: sampled_span_context) }

        log_records.each { |log_record| processor.emit(log_record, mock_context) }

        # mock_exporter.expect(:shutdown, nil, timeout: nil)
        mock_exporter.expect(:export, 0, [log_records[0..2]], timeout: nil)
        mock_exporter.expect(:export, 0, [[]], timeout: nil)
        # processor.shutdown
        # mock_exporter.verify
      end
    end

    # it 'respects the timeout' do
    # end

    it 'works if thread is nil' do
      processor.instance_variable_set(:@thread, nil)
      assert_equal(OpenTelemetry::SDK::Logs::Export::SUCCESS, processor.shutdown)
    end

    it 'reports dropped log records' do
    end
    it 'handles errors on fork' do
    end
    it 'handles errors on export' do
    end
    it 'handles timeouts on report' do
    end
    # delay works
    # queue size works 
  end
end
