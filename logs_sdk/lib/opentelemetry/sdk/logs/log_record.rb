# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # Implementation of OpenTelemetry::Logs::LogRecord that records log events.
      class LogRecord < OpenTelemetry::Logs::LogRecord
        EMPTY_ATTRIBUTES = {}.freeze

        private_constant :EMPTY_ATTRIBUTES

        attr_accessor :timestamp,
                      :observed_timestamp,
                      :severity_text,
                      :severity_number,
                      :body,
                      :attributes,
                      :trace_id,
                      :span_id,
                      :trace_flags,
                      :resource,
                      :instrumentation_scope

        # Creates a new {LogRecord}.
        #
        # @param [optional Time] timestamp Time when the event occurred.
        # @param [optional Time] observed_timestamp Time when the event
        #   was observed by the collection system. If nil, will first attempt
        #   to set to `timestamp`. If `timestamp` is nil, will set to Time.now.
        # @param [optional OpenTelemetry::Trace::SpanContext] span_context The
        #   OpenTelemetry::Trace::SpanContext to associate with the LogRecord.
        # @param [optional String] severity_text The log severity, also known as
        #   log level.
        # @param [optional Integer] severity_number The numerical value of the
        #   log severity.
        # @param [optional String, Numeric, Boolean, Array<String, Numeric,
        #   Boolean>, Hash{String => String, Numeric, Boolean, Array<String,
        #   Numeric, Boolean>}] body The body of the {LogRecord}.
        # @param [optional Hash{String => String, Numeric, Boolean,
        #   Array<String, Numeric, Boolean>}] attributes Attributes to associate
        #   with the {LogRecord}.
        # @param [optional String] trace_id The trace ID associated with the
        #   current context.
        # @param [optional String] span_id The span ID associated with the
        #   current context.
        # @param [optional OpenTelemetry::Trace::TraceFlags] trace_flags The
        #   trace flags associated with the current context.
        # @param [optional OpenTelemetry::SDK::Resources::Resource] recource The
        #   source of the log, desrived from the LoggerProvider.
        # @param [optional OpenTelemetry::SDK::InstrumentationScope] instrumentation_scope
        #   The instrumentation scope, derived from the emitting Logger
        # @param [optional] OpenTelemetry::SDK::LogRecordLimits] log_record_limits
        #   Attribute limits
        #
        #
        #
        # @return [LogRecord]
        def initialize(
          timestamp: nil,
          observed_timestamp: nil,
          severity_text: nil,
          severity_number: nil,
          body: nil,
          attributes: nil,
          trace_id: nil,
          span_id: nil,
          trace_flags: nil,
          resource: nil,
          instrumentation_scope: nil,
          log_record_limits: nil
        )
          @timestamp = timestamp
          @observed_timestamp = observed_timestamp || timestamp || Time.now
          @severity_text = severity_text
          @severity_number = severity_number
          @body = body
          @attributes = attributes.nil? ? nil : Hash[attributes] # We need a mutable copy of attributes
          @trace_id = trace_id
          @span_id = span_id
          @trace_flags = trace_flags
          @resource = resource
          @instrumentation_scope = instrumentation_scope
          @log_record_limits = log_record_limits || LogRecordLimits::DEFAULT
          @total_recorded_attributes = @attributes&.size || 0

          trim_attributes(@attributes)
        end

        def to_log_record_data
          LogRecordData.new(
            to_integer_nanoseconds(@timestamp),
            to_integer_nanoseconds(@observed_timestamp),
            @severity_text,
            @severity_number,
            @body,
            @attributes,
            @trace_id,
            @span_id,
            @trace_flags,
            @resource,
            @instrumentation_scope,
            @total_recorded_attributes
          )
        end

        private

        # Do we have sufficient logging for dropped attributes?
        # TODO: Validate attributes the same way as we do in Spans
        def trim_attributes(attributes)
          return if attributes.nil?

          attributes = validate_attribute_keys(attributes)
          excess = attributes.size - @log_record_limits.attribute_count_limit
          excess.times { attributes.shift } if excess.positive?
          truncate_attribute_values(attributes, @log_record_limits.attribute_length_limit)
          nil
        end

        def validate_attribute_keys(attributes)
          attributes.delete_if { |k, _v| !k.is_a?(String) || k.empty? }
        end

        def truncate_attribute_values(attributes, attribute_length_limit)
          return EMPTY_ATTRIBUTES if attributes.nil?
          return attributes if attribute_length_limit.nil?

          attributes.transform_values! { |value| OpenTelemetry::Common::Utilities.truncate_attribute_value(value, attribute_length_limit) }

          attributes
        end

        def to_integer_nanoseconds(timestamp)
          return unless timestamp.is_a?(Time)

          t = (timestamp.to_r * 10**9).to_i
        end
      end
    end
  end
end
