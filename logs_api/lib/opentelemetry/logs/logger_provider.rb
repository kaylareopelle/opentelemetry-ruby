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
      NOOP_LOGGER = OpenTelemetry::Logs::Logger.new

      # Returns an {OpenTelemetry::Logs::Logger} instance.
      #
      # @param [optional String] name Instrumentation package name
      # @param [optional String] version Instrumentation package version
      #
      # @return [OpenTelemetry::Logs::Logger]
      def logger(name = nil, version = nil)
        @logger ||= NOOP_LOGGER
      end
    end
  end
end
