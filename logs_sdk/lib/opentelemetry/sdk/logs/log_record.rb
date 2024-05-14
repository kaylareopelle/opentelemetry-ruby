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
        # @param [optional Float, Time] timestamp Time when the event occurred.
        # @param [optional Float, Time] observed_timestamp Time when the event
        #   was observed by the collection system. If nil, will first attempt
        #   to set to `timestamp`. If `timestamp` is nil, will set to
        #   `Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond)`.
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
        # @param [optional TraceFlags] trace_flags The trace flags associated
        #   with the current context.
        # @param [optional OpenTelemetry::SDK::Logs::Logger] logger The logger that
        #   created the {LogRecord}. Used to set `resource` and
        #   `instrumentation_scope`.
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
          logger: nil
        )
          @timestamp = timestamp
          @observed_timestamp = observed_timestamp || timestamp || Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond)
          @severity_text = severity_text
          @severity_number = severity_number
          @body = body
          @attributes = attributes.nil? ? nil : Hash[attributes] # We need a mutable copy of attributes
          @trace_id = trace_id
          @span_id = span_id
          @trace_flags = trace_flags
          @resource = logger&.resource
          @instrumentation_scope = logger&.instrumentation_scope
          @log_record_limits = logger&.log_record_limits || LogRecordLimits::DEFAULT
          @total_recorded_attributes = @attributes&.size || 0

          trim_attributes(@attributes)
        end

        def to_log_record_data
          LogRecordData.new(
            @timestamp,
            @observed_timestamp,
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
      end
    end
  end
end
