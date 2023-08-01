# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # The Logger is responsible for emitting LogRecords
    class Logger
      attr_reader :name, :version, :schema_url, :attributes

      def initialize(name:, version: nil, schema_url: nil, attributes: {})
        @name = name
        @version = version
        @schema_url = schema_url
        @attributes = attributes

        # Loggers are accessed through the logger_provider
        OpenTelemetry::Logs.logger_provider.loggers << self
      end

      # Emit a log record to the processing pipeline
      #
      # @param timestamp [optional Float] A timestamp, uint64 nanoseconds since Unix epoch, preferrably generated using `Process.clock_gettime(Process::CLOCK_REALTIME)`. Time when the event occurred measured by the origin clock, i.e. the time at the source. This field is optional, it may be missing if the source timestamp is unknown
      # @param observed_timestamp [optional Float] A timestamp, uint64 nanoseconds since Unix epoch, preferrably generated using `Process.clock_gettime(Process::CLOCK_REALTIME)`. Time when the event was observed by the collection system. Defaults to +Process.clock_gettime(Process::CLOCK_REALTIME)
      # @param context [optional Context] The Context to associate with the LogRecord. Defaults to +Context.current+
      # @param severity_number [optional Integer] Numerical value of the severity. Smaller numerical values correspond to less severe events (such as debug events), larger numerical values correspond to more severe events (such as errors and critical events).
      # @param body [optional String, Numeric, Boolean, Array<String, Numeric, Boolean>, Hash{String => String, Numeric, Boolean, Array<String, Numeric, Boolean>}] A value containing the body of the log record (see the description of any type above). Can be for example a human-readable string message (including multi-line) describing the event in a free form or it can be a structured data composed of arrays and maps of other values. First-party Applications SHOULD use a string message. However, a structured body SHOULD be used to preserve the semantics of structured logs emitted by Third-party Applications. Can vary for each occurrence of the event coming from the same source. This field is optional.
      #
      # @param attributes [optional Hash{String => String, Numeric, Boolean, Array<String, Numeric, Boolean>}]
      #
      # @api public
      def emit_log_record(
        timestamp: nil,
        observed_timestamp: Process.clock_gettime(Process::CLOCK_REALTIME),
        context: nil,
        severity_number: nil,
        severity_text: nil,
        body: nil,
        attributes: nil
      )

        OpenTelemetry::Logs::LogRecord.new(
          timestamp: timestamp,
          observed_timestamp: observed_timestamp,
          context: context || OpenTelemetry::Context.current,
          severity_number: severity_number,
          severity_text: severity_text,
          body: body,
          attributes: attributes
        )
      end
    end
  end
end
