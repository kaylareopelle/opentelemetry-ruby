# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # Class to provider access to Logger instances
    class LoggerProvider
      attr_reader :loggers

      def initialize
        @loggers = []
      end

      # Get a Logger instance
      #
      # This method searches the existing @loggers array for a Logger with an
      # identical name, version, and schema_url.
      #
      # @param name [String] This name uniquely identifies the instrumentation
      #  scope, such as the instrumentation library
      #  (e.g. io.opentelemetry.contrib.mongodb), package, module or class name.
      #  If an application or library has built-in OpenTelemetry
      #  instrumentation, both Instrumented library and Instrumentation library
      #  may refer to the same library. In that scenario, the name denotes a
      #  module name or component name within that library or application.
      # @param version [optional String] Specifies the version of the
      #  instrumentation scope if the scope has a version (e.g. a library
      #  version). Example value: 1.0.0.
      # @param schema_url [optional String] Specifies the Schema URL recorded
      #  in the emitted telemetry.
      # @param attributes [optional Hash] Specifies the instrumentation scope
      #  attributes to associate with emitted telemetry.
      # @return [OpenTelemetry::Logs::Logger]
      #
      # @api public
      def get_logger(name:, version: nil, schema_url: nil, attributes: {})
        loggers.find do |logger|
          logger.name == name &&
            logger.version == version &&
            logger.schema_url == schema_url
        end
      end
    end
  end
end
