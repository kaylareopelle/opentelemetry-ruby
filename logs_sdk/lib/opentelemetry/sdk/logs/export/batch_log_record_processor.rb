# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      module Export
        # WARNING - The spec has some differences from the Span version of this processor
        # Implementation of the duck type LogRecordProcessor that batches
        # log records exported by the SDK then pushes them to the exporter
        # pipeline.
        #
        # Typically, the BatchLogRecordProcessor will be more suitable for
        # production environments than the SimpleLogRecordProcessor.
        class BatchLogRecordProcessor < LogRecordProcessor
          # @param [Exporter] exporter The exporter where the {LogRecord}s are
          #   pushed.
          # @param [Integer] max_queue_size The maximum queue size. After the
          #   size is reached logs are dropped.
          # @param [Integer] scheduled_delay_millis The delay interval in
          #   milliseconds between two consecutive exports.
          # @param [Integer] export_timeout_millis The length of time the export
          #   can run before it is cancelled.
          # @param [Integer] max_export_batch_size The maximum batch size of
          #   every export. It must be smaller or equal to +max_queue_size+.
          def initialize(exporter,
                         exporter_timeout: 30_000,
                         schedule_delay: 1000,
                         max_queue_size: 2048,
                         max_export_batch_size: 512)

            unless max_export_batch_size <= max_queue_size
              raise ArgumentError,
                    'max_export_batch_size much be less than or equal to max_queue_size'
            end

            @exporter = exporter
            @max_queue_size = max_queue_size
            @scheduled_delay_millis = scheduled_delay_millis
            @export_timeout_millis = export_timeout_millis
            @max_export_batch_size = max_export_batch_size
          end

          def emit(log_record, context); end

          def shutdown(timeout: nil)
            start_time = OpenTelemetry::Common::Utilities.timetout_timestamp
            force_flush(timeout: OpenTelemetry::Common::Utilities.maybe_timeout(timeout, start_time))
            # KAY: handle stopping the logs or finishing things up
            # report dropped logs
            @exporter.shutdown(timeout: OpenTelemetry::Common::Utilities.maybe_timeout(timeout, start_time))
          end

          def force_flush(timeout: nil); end
        end
      end
    end
  end
end