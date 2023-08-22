# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::Logger do
  let(:logger_provider) { OpenTelemetry::SDK::Logs::LoggerProvider.new }
  let(:logger) { logger_provider.logger }

  describe '#resource' do
    it 'returns the resource associated with the logger_provider' do
      assert_equal(logger.resource, logger_provider.resource)
    end
  end
end
