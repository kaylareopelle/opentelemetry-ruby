# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Logs::LoggerProvider do
  let(:logger_provider) { OpenTelemetry::Logs::LoggerProvider.new }
  let(:args) do
    {
      name: 'component',
      version: '1.0',
      schema_url: 'schema_url',
      attributes: { a: 1 }
    }
  end

  describe '#logger' do
    it 'returns the same logger for the same arguments' do
      logger1 = logger_provider.logger(**args)
      logger2 = logger_provider.logger(**args)
      assert_same(logger1, logger2)
    end
  end
end
