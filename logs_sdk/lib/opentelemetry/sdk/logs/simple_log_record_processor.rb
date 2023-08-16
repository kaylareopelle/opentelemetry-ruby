# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Log
      module Export
        # An implementation of {LogRecordProcessor} which passes finished
        # logs and passes the export-friendly {ReadableLogRecord} representation
        # to the configured {LogRecordExporter}, as soon as they are finished.
        class SimpleLogRecordProcessor
          # Returns a new {SimpleLogRecordProcessor} that converts log records # to proto and forwards them to the given log_record_exporter.
          #
          # @param log_record_exporter the (duck type) LogRecordExporter to
          #   where the recorded LogRecords are pushed.
          # @return [SimpleLogRecordProcessor]
          # @raise ArgumentError if the log_record_exporter is nil.
          def initialize(log_record_exporter)
            raise ArgumentError, "exporter #{log_record_exporter.inspect} does not appear to be a valid exporter" unless Common::Utilities.valid_exporter?(log_record_exporter)

            @log_record_exporter = log_record_exporter
          end

          # KAY: Write me.
          def on_emit; end

          # Export all log records to the configured `Exporter` that have not
          # yet been exported, then call {Exporter#force_flush}.
          #
          # This method should only be called in cases where it is absolutely
          # necessary, such as when using some FaaS providers that may suspend
          # the process after an invocation, but before the `Processor` exports
          # the completed log records.
          #
          # @param [optional Numeric] timeout An optional timeout in seconds.
          # @return [Integer] SUCCESS if no error occurred, FAILURE if a
          #   non-specific failure occurred, TIMEOUT if a timeout occurred.
          def force_flush(timeout: nil)
            @log_record_exporter&.force_flush(timeout: timeout) || SUCCESS
          end

          # Called when {LoggerProvider#shutdown} is called.
          #
          # @param [optional Numeric] timeout An optional timeout in seconds.
          # @return [Integer] SUCCESS if no error occurred, FAILURE if a
          #   non-specific failure occurred, TIMEOUT if a timeout occurred.
          def shutdown(timeout: nil)
            @log_record_exporter&.shutdown(timeout: timeout) || SUCCESS
          end
        end
      end
    end
  end
end
