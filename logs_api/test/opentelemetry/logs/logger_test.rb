# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Logs::Logger do
  it 'adds created loggers to the logger_provider list of loggers' do
    logger = OpenTelemetry::Logs::Logger.new(name: 'name')
    assert_includes(OpenTelemetry::Logs.logger_provider.loggers, logger)
  end

  it 'raises an argument error if name is not present' do
    assert_raises(ArgumentError) { OpenTelemetry::Logs::Logger.new }
  end

  it 'does not raise an argument error if name is present' do
    assert(OpenTelemetry::Logs::Logger.new(name: 'hi'))
  end

  it 'optionally accepts version, schema_url, and attributes' do
    assert(OpenTelemetry::Logs::Logger.new(name: 'name', version: '1.0', schema_url: 'hi', attributes: { a: 1 }))
  end

  describe '#emit_log_record' do
    let(:logger) { OpenTelemetry::Logs::Logger.new(name: 'test') }
    it 'has no required parameters' do
      assert(logger.emit_log_record)
    end

    it 'optionally accepts timestamp, observed_timestamp, context, severity_number, severity_text, body, and attributes' do
      time = Process.clock_gettime(Process::CLOCK_REALTIME)
      assert(logger.emit_log_record(
               timestamp: time,
               observed_timestamp: time,
               context: '',
               severity_number: 1,
               severity_text: 'DEBUG',
               body: "Captain's log, Stardate 4525.6",
               attributes: { trouble: 'tribbles' }
             ))
    end

    it 'emits a LogRecord to the processing pipeline' do
      # need details
    end
  end
end
