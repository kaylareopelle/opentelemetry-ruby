# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # The Logger is responsible for emitting LogRecords
    class LogRecord
      attr_reader :timestamp, :observed_timestamp, :context, :severity_number, :severity_text, :body, :attributes

      def initialize(
        timestamp: nil,
        observed_timestamp: Process.clock_gettime(Process::CLOCK_REALTIME),
        context: nil,
        severity_number: nil,
        severity_text: nil,
        body: nil,
        attributes: nil
      )

        @timestamp = timestamp
        @observed_timestamp = observed_timestamp
        @context = context # may use the current contex
        @severity_number = severity_number
        @severity_text = severity_text
        @body = body
        @attributes = attributes

        # add to processing pipeline
      end
    end
  end
end
