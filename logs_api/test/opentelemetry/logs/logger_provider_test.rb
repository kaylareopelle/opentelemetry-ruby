# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Logs::LoggerProvider do
  let(:logger_provider) { OpenTelemetry::Logs::LoggerProvider.new }
  let(:args) { { name: 'component', version: '1.0' } }

  describe '#logger' do
    it 'returns the NOOP_LOGGER' do
      logger1 = logger_provider.logger(**args)
      assert_same(logger1, OpenTelemetry::Logs::LoggerProvider::NOOP_LOGGER)
    end
  end
end
