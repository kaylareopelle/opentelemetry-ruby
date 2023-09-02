# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::LogRecord do
  let(:log_record) { OpenTelemetry::SDK::Logs::LogRecord.new(**args) }
  let(:args) { {} }

  describe '#initialize' do
    describe 'observed_timestamp' do
      describe 'when observed_timestamp is present' do
        let(:observed_timestamp) { '1692661486.2841358' }
        let(:args) { { observed_timestamp: observed_timestamp } }

        it 'is equal to observed_timestamp' do
          assert_equal(observed_timestamp, log_record.observed_timestamp)
        end

        it 'is not equal to timestamp' do
          refute_equal(log_record.timestamp, log_record.observed_timestamp)
        end

        # Process.clock_gettime is used to set the current time
        # That method returns a Float. Since the stubbed value of
        # observed_timestamp is a String, we can know the the
        # observed_timestamp was not set to the value of Process.clock_gettime
        # by making sure its value is not a Float.
        it 'is not equal to the current time' do
          refute_instance_of(Float, log_record.observed_timestamp)
        end
      end

      describe 'when timestamp is present' do
        let(:timestamp) { Process.clock_gettime(Process::CLOCK_REALTIME) }
        let(:args) { { timestamp: timestamp } }

        it 'is equal to timestamp' do
          assert_equal(timestamp, log_record.observed_timestamp)
        end
      end

      describe 'when observed_timestamp and timestamp are nil' do
        let(:args) { { timestamp: nil, observed_timestamp: nil } }

        it 'is not nil' do
          refute_nil(log_record.observed_timestamp)
        end

        it 'is equal to the current time' do
          # Since I can't get the current time when the test was run
          # I'm going to assert it's a Float, which is the Process.clock_gettime
          # return value class.
          assert_instance_of(Float, log_record.observed_timestamp)
        end
      end
    end

    describe 'attributes set through logger' do
      let(:logger_provider) { OpenTelemetry::SDK::Logs::LoggerProvider.new }
      let(:resource) { OpenTelemetry::SDK::Resources::Resource.create }
      let(:instrumentation_scope) { OpenTelemetry::SDK::InstrumentationScope.new('name', 'version') }
      let(:logger) { OpenTelemetry::SDK::Logs::Logger.new(resource, instrumentation_scope, logger_provider) }
      let(:args) { { logger: logger } }

      describe 'resource' do
        it 'is set to the resource of the logger given on initialization' do
          assert_equal(logger.resource, log_record.resource)
        end
      end

      describe 'instrumentation_scope' do
        it 'is set to the instrumentation_scope of the logger given on initialization' do
          assert_equal(logger.instrumentation_scope, log_record.instrumentation_scope)
        end
      end

      describe 'when logger is nil' do
        let(:logger) { nil }

        it 'sets the resource to nil' do
          assert_nil(log_record.resource)
        end

        it 'sets the instrumentation_scope to nil' do
          assert_nil(log_record.instrumentation_scope)
        end
      end
    end
  end
end