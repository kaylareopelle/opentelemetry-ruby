# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Logs::LoggerProvider do
  let(:logger_provider) { OpenTelemetry::Logs.logger_provider }
  # let(:name) not allowed in Minitest
  let(:name_attr) { 'name' }
  let(:version) { 'version' }
  let(:schema_url) { 'schema_url' }
  let(:logger) do
    OpenTelemetry::Logs::Logger.new(
      name: name_attr,
      version: version,
      schema_url: schema_url,
      attributes: {}
    )
  end
  let(:second_logger) { OpenTelemetry::Logs::Logger.new(name: 'test') }

  after { OpenTelemetry::Logs.logger_provider.instance_variable_set(:@loggers, []) }

  describe 'LoggerProvider' do
    it 'provides access to loggers' do
      assert_includes(logger_provider.loggers, logger)
      assert_includes(logger_provider.loggers, second_logger)
    end

    describe '#get_logger' do
      it 'raises an argument error if name is not present' do
        assert_raises(ArgumentError) { logger_provider.get_logger }
      end

      it 'does not raise an argument error if name is present' do
        assert(logger_provider.get_logger(name: second_logger.name))
      end

      it 'optionally accepts version, schema_url, and attributes' do
        assert(logger_provider.get_logger(name: logger.name, version: version, schema_url: schema_url, attributes: {}))
      end

      it 'gets a logger based on matching name, version, and schema_url' do
        assert_equal(logger, logger_provider.get_logger(name: name_attr, version: version, schema_url: schema_url))
      end

      it 'returns nil if no logger has a matching name, version, and schema_url' do
        assert_nil(logger_provider.get_logger(name: '', version: version, schema_url: schema_url))
      end

      it 'returns the first logger when two loggers with identical identifying fields but different attributes exist' do
        test_name = 'test_name'
        first = OpenTelemetry::Logs::Logger.new(name: test_name, attributes: { a: 1 })
        OpenTelemetry::Logs::Logger.new(name: test_name, attributes: { b: 2 })
        assert_equal(first, logger_provider.get_logger(name: test_name, attributes: { b: 2 }))
      end
    end
  end
end
