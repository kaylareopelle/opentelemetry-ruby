# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::Logs::Logger do
  it 'adds created loggers to the logger_provider list of loggers' do
    logger = OpenTelemetry::Logs::Logger.new(name: 'name')
    assert_includes(OpenTelemetry::Logs.logger_provider.loggers, logger)
  end

  it 'raises an argument error if name is not present' do
    assert_raises(ArgumentError) { OpenTelemetry::Logs::Logger.new }
  end

  it 'does not raise an argument error if name is present' do
    assert(OpenTelemetry::Logs::Logger.new(name: 'hi'))
  end

  it 'optionally accepts version, schema_url, and attributes' do
    assert(OpenTelemetry::Logs::Logger.new(name: 'name', version: '1.0', schema_url: 'hi', attributes: { a: 1 }))
  end
end
