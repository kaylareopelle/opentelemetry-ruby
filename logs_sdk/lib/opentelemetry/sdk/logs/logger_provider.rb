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
        # @param [optional Array] log_record_processors to associate with the
        #   LoggerProvider
        #
        # @return [LoggerProvider]
        def initialize(
          resource: OpenTelemetry::SDK::Resources::Resource.create,
          log_record_processors: []
        )
          @mutex = Mutex.new
          @resource = resource
          @log_record_processors = log_record_processors
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

          # Q: Why does the TracerProvider have both @mutex and @registry_mutex?
          @mutex.synchronize do
            OpenTelemetry::SDK::Logs::Logger.new(name, version, self)
          end
        end

        # Adds a new LogRecordProcessor to this {LoggerProvider}.
        #
        # @param log_record_processor the new LogRecordProcessor to be added
        def add_log_record_processor(log_record_processor)
          @mutex.synchronize do
            @log_record_processors = @log_record_processors.dup.push(log_record_processor)
          end
        end
      end
    end
  end
end
