# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # A {LogRecord} interface that can write to the full {LogRecord} and
      # retrieve all information added to the {LogRecord}.
      class ReadWriteLogRecord < OpenTelemetry::Logs::LogRecord
        attr_accessor :timestamp,
                      :observed_timestamp,
                      :trace_id,
                      :span_id,
                      :trace_flags,
                      :severity_text,
                      :severity_number,
                      :body,
                      :attributes,
                      :resource,
                      :information_scope

        # Creates a new {ReadWriteLogRecord}.
        #
        # @param [optional Float, Time] timestamp Time when the event occurred.
        # @param [optional String] trace_id The trace ID associated with a {ReadWriteLogRecord}.
        # @param [optional String] span_id The span ID associated with a {ReadWriteLogRecord}.
        # @param [optional TraceFlags] trace_flags The trace flags associated with a {ReadWriteLogRecord}.
        # @param [optional String] severity_text The log severity, also known as log level.
        # @param [optional Integer] severity_number The numerical value of the log severity.
        # @param [optional String, Numeric, Boolean, Array<String, Numeric,
        #   Boolean>, Hash{String => String, Numeric, Boolean, Array<String,
        #   Numeric, Boolean>}] body The body of the {ReadWriteLogRecord}.
        # @param [optional Hash] attributes Additional information about the event.
        #
        # @return [ReadWriteLogRecord]
        def initialize(
          timestamp: nil,
          trace_id: nil,
          span_id: nil,
          trace_flags: nil,
          severity_text: nil,
          severity_number: nil,
          body: nil,
          attributes: nil,
          logger: nil
        )
          @timestamp = timestamp
          @observed_timestamp = timestamp || Process.clock_gettime(Process::CLOCK_REALTIME)
          @trace_id = trace_id
          @span_id = span_id
          @trace_flags = trace_flags
          @severity_text = severity_text
          @severity_number = severity_number
          @body = body
          @resource = logger.resource
          @instrumentation_scope = logger.instrumentation_scope
          @attributes = attributes || {}
        end
      end
    end
  end
end
