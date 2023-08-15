# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::LoggerProvider do
  let(:logger_provider) { OpenTelemetry::SDK::Logs::LoggerProvider.new }

  describe 'resource association' do
    let(:resource) { OpenTelemetry::SDK::Resources::Resource.create('hi' => 1) }
    let(:logger_provider) { OpenTelemetry::SDK::Logs::LoggerProvider.new(resource: resource) }

    it 'allows a resource to be associated with the logger provider' do
      assert_instance_of(OpenTelemetry::SDK::Resources::Resource, logger_provider.resource)
    end
  end

  describe '#add_log_record_processor' do
    let(:mock_log_record_processor) { Minitest::Mock.new }

    it "adds the processor to the logger provider's processors" do
      assert_equal(0, logger_provider.instance_variable_get(:@log_record_processors).length)
      logger_provider.add_log_record_processor(mock_log_record_processor)
      assert_equal(1, logger_provider.instance_variable_get(:@log_record_processors).length)
    end
  end

  describe '#logger' do
    it 'logs a warning if name is nil' do
      OpenTelemetry::TestHelpers.with_test_logger do |log_stream|
        logger_provider.logger(nil)
        assert_match(
          /#{OpenTelemetry::SDK::Logs::LoggerProvider::EMPTY_NAME_ERROR}/,
          log_stream.string
        )
      end
    end

    it 'logs a warning if name is an empty string' do
      OpenTelemetry::TestHelpers.with_test_logger do |log_stream|
        logger_provider.logger('')
        assert_match(
          /#{OpenTelemetry::SDK::Logs::LoggerProvider::EMPTY_NAME_ERROR}/,
          log_stream.string
        )
      end
    end

    it 'sets name to an empty string if nil' do
      logger = logger_provider.logger(nil)
      assert_equal(logger.instrumentation_scope.name, '')
    end

    it 'sets version to an empty string if nil' do
      logger = logger_provider.logger('name', nil)
      assert_equal(logger.instrumentation_scope.version, '')
    end

    it 'creates a new logger with the passed-in name and version' do
      name = 'name'
      version = 'version'
      logger = logger_provider.logger(name, version)
      assert_equal(logger.instrumentation_scope.name, name)
      assert_equal(logger.instrumentation_scope.version, version)
    end

    it 'creates a new logger when name and version are missing' do
      logger = logger_provider.logger
      logger2 = logger_provider.logger

      refute_same(logger, logger2)
      assert_instance_of(OpenTelemetry::SDK::Logs::Logger, logger)
    end
  end

  describe '#shutdown' do
    # TODO: Figure out why the argument isn't working on expect/in method
    let(:mock_log_record_processor) { Minitest::Mock.new }

    it 'logs a warning if called twice' do
      OpenTelemetry::TestHelpers.with_test_logger do |log_stream|
        logger_provider.shutdown
        assert logger_provider.instance_variable_get(:@stopped)
        assert_empty(log_stream.string)
        logger_provider.shutdown
        assert_match(/calling .* multiple times/, log_stream.string)
      end
    end

    it 'sends shutdown to the processor' do
      # mock_log_record_processor.expect(:shutdown, nil, [{timeout: nil}])
      mock_log_record_processor.expect(:shutdown, nil)
      logger_provider.add_log_record_processor(mock_log_record_processor)
      logger_provider.shutdown
      mock_log_record_processor.verify
    end

    it 'sends shutdown to multiple processors' do
      mock_log_record_processor2 = Minitest::Mock.new
      # mock_log_record_processor.expect(:shutdown, nil, [{timeout: nil}])
      # mock_log_record_processor2.expect(:shutdown, nil, [{timeout: nil}])
      mock_log_record_processor.expect(:shutdown, nil)
      mock_log_record_processor2.expect(:shutdown, nil)

      logger_provider.instance_variable_set(:@log_record_processors, [mock_log_record_processor, mock_log_record_processor2])
      logger_provider.shutdown

      mock_log_record_processor.verify
      mock_log_record_processor2.verify
    end

    it 'only notifies the processor once' do
      # mock_log_record_processor.expect(:shutdown, nil, [{timeout: nil}])
      mock_log_record_processor.expect(:shutdown, nil)
      logger_provider.add_log_record_processor(mock_log_record_processor)
      logger_provider.shutdown
      logger_provider.shutdown
      mock_log_record_processor.verify
    end
  end

  describe '#force_flush' do
    let(:mock_log_record_processor)  { Minitest::Mock.new }
    let(:mock_log_record_processor2) { Minitest::Mock.new }

    it 'notifies the log record processor' do
      # mock_log_record_processor.expect(:force_flush, nil, [{timeout: nil}])
      mock_log_record_processor.expect(:force_flush, nil)
      logger_provider.add_log_record_processor(mock_log_record_processor)
      logger_provider.force_flush
      mock_log_record_processor.verify
    end

    it 'supports multiple log record processors' do
      # mock_log_record_processor.expect(:force_flush, nil, [{timeout: nil}])
      # mock_log_record_processor2.expect(:force_flush, nil, [{timeout: nil}])
      mock_log_record_processor.expect(:force_flush, nil)
      mock_log_record_processor2.expect(:force_flush, nil)
      logger_provider.add_log_record_processor(mock_log_record_processor)
      logger_provider.add_log_record_processor(mock_log_record_processor2)
      logger_provider.force_flush
      mock_log_record_processor.verify
      mock_log_record_processor2.verify
    end
  end
end
