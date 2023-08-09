# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # {LoggerProvider} is the SDK implementation of
      # {OpenTelemetry::Logs::LoggerProvider}.
      class LoggerProvider < OpenTelemetry::Logs::LoggerProvider
        attr_reader :resource

        EMPTY_NAME_ERROR = 'LoggerProvider#logger called without '\
            'providing a logger name.'

        # Returns a new {LoggerProvider} instance.
        #
        # @param [optional Resource] resource The resource to associate with new
        #   LogRecords created by Loggers created by this LoggerProvider
        #
        # @return [LoggerProvider]
        def initialize(resource: OpenTelemetry::SDK::Resources::Resource.create)
          @resource = resource
        end

        # Returns a {OpenTelemetry::SDK::Logs::Logger} instance.
        #
        # @param [optional String] name Instrumentation package name
        # @param [optional String] version Instrumentation package version
        #
        # @return [OpenTelemetry::SDK::Logs::Logger]
        def logger(name = nil, version = nil)
          name ||= ''
          version ||= ''

          OpenTelemetry.logger.warn(EMPTY_NAME_ERROR) if name.empty?

          # Q: @registry_mutex.synchronize invokes similar code within a block in the TracerProvider. Is that needed here for async safety?
          OpenTelemetry::SDK::Logs::Logger.new(name, version, self)
        end
      end
    end
  end
end
