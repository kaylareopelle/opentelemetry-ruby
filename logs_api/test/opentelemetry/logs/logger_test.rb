# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Logs::Logger do
  let(:logger) { OpenTelemetry::Logs::Logger.new }

  describe '#create_log_record' do
    it 'creates a new LogRecord' do
      assert_instance_of(OpenTelemetry::Logs::LogRecord, logger.create_log_record)
    end
  end
end
