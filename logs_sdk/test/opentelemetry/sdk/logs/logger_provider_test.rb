# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::LoggerProvider do
  let(:logger_provider) { OpenTelemetry::SDK::Logs::LoggerProvider.new }

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
end
