# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # No-op implementation of a logger provider.
    #
    # The Logs Bridge API is provided for logging library authors to build
    # log appenders/bridges. It should NOT be used directly by application
    # developers.
    class LoggerProvider
      # Returns a {Logger} instance.
      #
      # @param name [optional String] Instrumentation package name
      # @param version [optional String] Instrumentation package version
      # @param schema_url [optional String] Schema URL recorded in the emitted
      #   telemetry.
      # @param attributes [optional Hash] Specifies the instrumentation scope
      #   attributes to associate with emitted telemetry.
      #
      # @return [OpenTelemetry::Logs::Logger]
      #
      # @api public
      def logger(name: nil, version: nil, schema_url: nil, attributes: {})
        @logger ||= OpenTelemetry::Logs::Logger.new
      end
    end
  end
end
