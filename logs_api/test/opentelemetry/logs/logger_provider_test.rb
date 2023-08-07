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
      assert_same(
        OpenTelemetry::Logs::LoggerProvider::NOOP_LOGGER,
        logger_provider.logger(**args)
      )
    end
  end
end
