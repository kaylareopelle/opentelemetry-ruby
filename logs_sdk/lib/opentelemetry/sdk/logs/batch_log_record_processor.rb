# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # Implementation of the duck type LogRecordProcessor that batches
      # log records exported by the SDK then pushes them to the exporter
      # pipeline.
      #
      # Typically, the BatchLogRecordProcessor will be more suitable for
      # production environments than the SimpleLogRecordProcessor.
      class BatchLogRecordProcessor
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
        def initialize(exporter: nil,
                       max_queue_size: 2048,
                       scheduled_delay_millis: 1000,
                       export_timeout_millis: 30_000,
                       max_export_batch_size: 512)
          @exporter = exporter
          @max_queue_size = max_queue_size
          @scheduled_delay_millis = scheduled_delay_millis
          @export_timeout_millis = export_timeout_millis
          @max_export_batch_size = max_export_batch_size
        end

        def on_emit(log_record, context); end

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
