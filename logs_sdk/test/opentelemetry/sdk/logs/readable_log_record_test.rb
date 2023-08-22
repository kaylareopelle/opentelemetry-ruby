# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::ReadableLogRecord do
  let(:readable_log_record) { OpenTelemetry::SDK::Logs::ReadableLogRecord.new(**args) }
  let(:args) { {} }

  describe 'attributes' do
    let(:new_value) { 'new_value' }

    describe 'timestamp' do
      let(:timestamp) { Process.clock_gettime(Process::CLOCK_REALTIME) }
      let(:args) { { timestamp: timestamp } }

      it 'is set to the value given on initialization' do
        assert_equal(timestamp, readable_log_record.timestamp)
      end

      it 'can be read' do
        assert(readable_log_record.timestamp)
      end

      it 'cannot be rewritten' do
        assert_raises(FrozenError) { readable_log_record.timestamp = new_value }
      end
    end

    describe 'observed_timestamp' do
      describe 'when observed_timestamp is present' do
        let(:observed_timestamp) { '1692661486.2841358' }
        let(:args) { { observed_timestamp: observed_timestamp } }

        it 'is equal to observed_timestamp' do
          assert_equal(observed_timestamp, readable_log_record.observed_timestamp)
        end

        it 'is not equal to timestamp' do
          refute_equal(readable_log_record.timestamp, readable_log_record.observed_timestamp)
        end

        # Process.clock_gettime is used to set the current time
        # That method returns a Float. Since the stubbed value of
        # observed_timestamp is a String, we can know the the
        # observed_timestamp was not set to the value of Process.clock_gettime
        # by making sure its value is not a Float.
        it 'is not equal to the current time' do
          refute_instance_of(Float, readable_log_record.observed_timestamp)
        end
      end

      describe 'when timestamp is present' do
        let(:timestamp) { Process.clock_gettime(Process::CLOCK_REALTIME) }
        let(:args) { { timestamp: timestamp } }

        it 'is equal to timestamp' do
          assert_equal(timestamp, readable_log_record.observed_timestamp)
        end
      end

      describe 'when observed_timestamp and timestamp are nil' do
        let(:args) { { timestamp: nil, observed_timestamp: nil } }

        it 'is not nil' do
          refute_nil(readable_log_record.observed_timestamp)
        end

        it 'is equal to the current time' do
          # Since I can't get the current time when the test was run
          # I'm going to assert it's a Float, which is the Process.clock_gettime
          # return value class.
          assert_instance_of(Float, readable_log_record.observed_timestamp)
        end
      end

      it 'can be read' do
        assert(readable_log_record.observed_timestamp)
      end

      it 'cannot be rewritten' do
        assert_raises(FrozenError) { readable_log_record.observed_timestamp = new_value }
      end
    end

    describe ':span_context' do
      let(:span_context) { OpenTelemetry::Trace::SpanContext.new }
      let(:args) { { span_context: span_context } }

      it 'is set to the value given on initialization' do
        assert_equal(span_context, readable_log_record.span_context)
      end

      it 'can be read' do
        assert(readable_log_record.span_context)
      end

      it 'cannot be rewritten' do
        assert_raises(FrozenError) { readable_log_record.span_context = new_value }
      end
    end

    describe 'severity_text' do
      let(:severity_text) { 'DEBUG' }
      let(:args) { { severity_text: severity_text } }

      it 'is set to the value given on initialization' do
        assert_equal(severity_text, readable_log_record.severity_text)
      end

      it 'can be read' do
        assert(readable_log_record.severity_text)
      end

      it 'cannot be rewritten' do
        assert_raises(FrozenError) { readable_log_record.severity_text = new_value }
      end
    end

    describe 'severity_number' do
      let(:severity_number) { OpenTelemetry::Logs::SeverityNumber::TRACE }
      let(:args) { { severity_number: severity_number } }

      it 'is set to the value given on initialization' do
        assert_equal(severity_number, readable_log_record.severity_number)
      end

      it 'can be read' do
        assert(readable_log_record.severity_number)
      end

      it 'cannot be rewritten' do
        assert_raises(FrozenError) { readable_log_record.severity_number = new_value }
      end
    end

    describe 'body' do
      let(:body) { 'Log message' }
      let(:args) { { body: body } }

      it 'is set to the value given on initialization' do
        assert_equal(body, readable_log_record.body)
      end

      it 'can be read' do
        assert(readable_log_record.body)
      end

      it 'cannot be rewritten' do
        assert_raises(FrozenError) { readable_log_record.body = new_value }
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
          assert_equal(logger.resource, readable_log_record.resource)
        end

        it 'can be read' do
          assert(readable_log_record.resource)
        end

        it 'cannot be rewritten' do
          assert_raises(FrozenError) { readable_log_record.resource = new_value }
        end
      end

      describe 'instrumentation_scope' do
        it 'is set to the instrumentation_scope of the logger given on initialization' do
          assert_equal(logger.instrumentation_scope, readable_log_record.instrumentation_scope)
        end

        it 'can be read' do
          assert(readable_log_record.instrumentation_scope)
        end

        it 'cannot be rewritten' do
          assert_raises(FrozenError) { readable_log_record.instrumentation_scope = new_value }
        end
      end

      describe 'when logger is nil' do
        let(:logger) { nil }

        it 'sets the resource to nil' do
          assert_nil(readable_log_record.resource)
        end

        it 'sets the instrumentation_scope to nil' do
          assert_nil(readable_log_record.instrumentation_scope)
        end
      end
    end

    describe 'attributes' do
      let(:attributes) { { a: 1 } }
      let(:args) { { attributes: attributes } }

      it 'is set to the value given on initialization' do
        assert_equal(attributes, readable_log_record.attributes)
      end

      it 'can be read' do
        assert(readable_log_record.attributes)
      end

      it 'cannot be rewritten' do
        assert_raises(FrozenError) { readable_log_record.attributes = new_value }
      end
    end
  end
end
