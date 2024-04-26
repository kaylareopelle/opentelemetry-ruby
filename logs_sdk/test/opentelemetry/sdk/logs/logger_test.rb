# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::Logger do
  let(:logger_provider) { OpenTelemetry::SDK::Logs::LoggerProvider.new }
  let(:logger) { logger_provider.logger(name: 'default_logger') }

  describe '#resource' do
    it 'returns the resource associated with the logger_provider' do
      assert_equal(logger.resource, logger_provider.resource)
    end
  end

  describe '#on_emit' do
    it 'creates a new LogRecord' do
      output = 'chocolate cherry'
      OpenTelemetry::SDK::Logs::LogRecord.stub(:new, ->(_) { puts output }) do
        assert_output(/#{output}/) { logger.on_emit }
      end
    end

    it 'sends the newly-created log record to the logger provider' do
      skip 'needs to be reworked for the new strategy with logger provider'
      mock_log_record = Minitest::Mock.new
      mock_context = Minitest::Mock.new
      def mock_context.value(value) = nil

      OpenTelemetry::SDK::Logs::LogRecord.stub(:new, ->(_) { mock_log_record }) do
        mock_logger_provider = Minitest::Mock.new

        mock_logger_provider.expect(:on_emit, nil, [mock_log_record, mock_context])
        logger.on_emit(context: mock_context)
        mock_logger_provider.verify
      end
    end

    describe 'when the provider has no processors' do
      it 'does not error' do
        logger_provider.instance_variable_set(:@log_record_processors, [])
        assert(logger.on_emit)
      end
    end
  end
end
