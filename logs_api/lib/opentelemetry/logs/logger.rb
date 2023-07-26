# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # No-op implementation of logger.
    class Logger
      # Create a {LogRecord}
      #
      # @param timestamp [optional Float, Time] Time in nanoseconds since Unix
      #   epoch when the event occurred measured by the origin clock, i.e. the
      #   time at the source.
      # @param observed_timestamp [optional Float, Time] Time in nanoseconds
      #   since Unix epoch when the event was observed by the collection system.
      #   Defaults to +Process.clock_gettime(Process::CLOCK_REALTIME)+.
      # @param context [optional Context] The Context to associate with the
      #   LogRecord. Defaults to +OpenTelemetry::Context.current+.
      # @param severity_number [optional Integer] Numerical value of the
      #   severity. Smaller numerical values correspond to less severe events
      #   (such as debug events), larger numerical values correspond to more
      #   severe events (such as errors and critical events).
      # @param severity_text [optional String] Original string representation of
      #   the severity as it is known at the source. Also known as log level.
      # @param body [optional String, Numeric, Boolean, Array<String, Numeric,
      #   Boolean>, Hash{String => String, Numeric, Boolean, Array<String,
      #   Numeric, Boolean>}] A value containing the body of the log record.
      # @param attributes [optional Hash{String => String, Numeric, Boolean,
      #   Array<String, Numeric, Boolean>}] Additional information about the
      #   event.
      #
      # @api public
      def create_log_record(
        timestamp: nil,
        observed_timestamp: Process.clock_gettime(Process::CLOCK_REALTIME),
        context: OpenTelemetry::Context.current,
        severity_number: nil,
        severity_text: nil,
        body: nil,
        attributes: nil
      )
        LogRecord.new
      end
    end
  end
end
