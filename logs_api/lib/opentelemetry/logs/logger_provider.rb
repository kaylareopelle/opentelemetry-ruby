# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # No-op implementation of a logger provider.
    class LoggerProvider
      NOOP_LOGGER = OpenTelemetry::Logs::Logger.new
      # TODO: Make NOOP_LOGGER private again
      # NOOP_LOGGER is used in the SDK logger at this time until the ProxyLogger has been created
      # private_constant :NOOP_LOGGER

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
