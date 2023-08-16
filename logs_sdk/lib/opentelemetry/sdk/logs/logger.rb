# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # {OpenTelemetry::SDK::Logs::Logger} is the SDK implementation of
      # {OpenTelemetry::Logs::Logger}
      class Logger < OpenTelemetry::Logs::Logger
        attr_reader :instrumentation_scope

        # @api private
        #
        # Returns a new {OpenTelemetry::SDK::Logs::Logger} instance.
        #
        # @param [String] name Instrumentation package name
        # @param [String] version Instrumentation package version
        # @param [LoggerProvider] logger_provider LoggerProvider that
        #   initialized the logger
        #
        # @return [OpenTelemetry::SDK::Logs::Logger]
        def initialize(name, version, logger_provider)
          @instrumentation_scope = InstrumentationScope.new(name, version)
          @logger_provider = logger_provider
        end
      end
    end
  end
end
