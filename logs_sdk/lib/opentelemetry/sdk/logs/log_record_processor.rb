# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # TODO: Implement diffs b/w spec for logs & traces:
      # Logs MUST: "decorate built-in processors for advanced scenarios such as enriching with attributes."
      class LogRecordProcessor
        # Called when a {LogRecord} is emitted. Subsequent calls are not
        # permitted after shutdown is called.
        # @param [LogRecord] log_record The emitted {ReadWriteLogRecord}
        # @param [Context] context The resolved Context
        # TODO: Context or SpanContext here? What's the difference?
        def emit(log_record, context); end

        # Export all log records to the configured `Exporter` that have not yet
        # been exported.
        #
        # This method should only be called in cases where it is absolutely
        # necessary, such as when using some FaaS providers that may suspend
        # the process after an invocation, but before the `Processor` exports
        # the completed spans.
        #
        # @param [optional Numeric] timeout An optional timeout in seconds.
        # @return [Integer] Export::SUCCESS if no error occurred, Export::FAILURE if
        #   a non-specific failure occurred, Export::TIMEOUT if a timeout occurred.
        def force_flush(timeout: nil)
          Export::SUCCESS
        end

        # Called when {LoggerProvider#shutdown} is called.
        #
        # @param [optional Numeric] timeout An optional timeout in seconds.
        # @return [Integer] Export::SUCCESS if no error occurred, Export::FAILURE if
        #   a non-specific failure occurred, Export::TIMEOUT if a timeout occurred.
        def shutdown(timeout: nil)
          Export::SUCCESS
        end
      end
    end
  end
end
