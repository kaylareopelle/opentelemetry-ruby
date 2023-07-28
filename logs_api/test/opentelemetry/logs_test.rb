# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Logs do
  describe '#logger_provider' do
    it 'returns an instance of LoggerProvider' do
      assert_equal(OpenTelemetry::Logs::LoggerProvider, OpenTelemetry::Logs.logger_provider.class)
    end

    it 'always uses the same LoggerProvider' do
      first_call = OpenTelemetry::Logs.logger_provider
      second_call = OpenTelemetry::Logs.logger_provider
      assert_same(first_call, second_call)
    end
  end
end
