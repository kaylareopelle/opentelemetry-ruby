# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require_relative 'log_record/readable_log_record'
require_relative 'log_record/readwrite_log_record'

module OpenTelemetry
  module SDK
    module Logs
      # The SDK implementation of the OpenTelemetry logs data model
      class LogRecord < OpenTelemetry::Logs::LogRecord
        # Creates a new {LogRecord}.
        #
        # @param [optional Float, Time] timestamp Time when the event occurred.
        # @param [optional Float, Time] observed_timestamp Time when the event was observed.

        # KAY: Should these three be a SpanContext object? Or maybe Context.current?
        # php - context.current: https://github.com/open-telemetry/opentelemetry-php/blob/main/src/SDK/Logs/ReadableLogRecord.php
        # java - spancontext: https://github.com/open-telemetry/opentelemetry-java/blob/main/sdk/logs/src/main/java/io/opentelemetry/sdk/logs/data/LogRecordData.java
        # python - has trace_id, span_id, trace_flags individually: https://github.com/open-telemetry/opentelemetry-python/blob/c9277ffb137fad999ee14bee4f99bad2d00b8b03/opentelemetry-sdk/src/opentelemetry/sdk/_logs/_internal/__init__.py#L150
        # js - context: https://github.com/open-telemetry/opentelemetry-js/blob/853a7b6edeb584e800499dbb65a3b42aa45c87e8/experimental/packages/api-logs/src/types/LogRecord.ts#L24
        # @param [optional String] trace_id The trace ID associated with a {LogRecord}.
        # @param [optional String] span_id The span ID associated with a {LogRecord}.
        # @param [optional TraceFlags] trace_flags The trace flags associated with a {LogRecord}.

        # @param [optional String] severity_text The log severity, also known as log level.
        # KAY: Do I need to add this to the API?
        # @param [optional Integer] severity_number The numerical value of the log severity.
        # @param [optional String, Numeric, Boolean, Array<String, Numeric,
        #   Boolean>, Hash{String => String, Numeric, Boolean, Array<String,
        #   Numeric, Boolean>}] body The body of the {LogRecord}.
        # @param [optional Hash] attributes Additional information about the event.
        #
        # @return [LogRecord]
        def initialize(
          timestamp: nil,
          observed_timestamp: nil,
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
