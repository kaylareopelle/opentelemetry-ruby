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
    end
  end
end
