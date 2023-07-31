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
          context: context,
          severity_number: severity_number,
          severity_text: severity_text,
          body: body,
          attributes: attributes
        )
      end
    end
  end
end
