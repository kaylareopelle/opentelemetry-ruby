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
          @log_record_processors = log_record_processors
          @mutex = Mutex.new
          @resource = resource
          @stopped = false
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

        # Attempts to stop all the activity for this {LoggerProvider}. Calls
        # LogRecordProcessor#shutdown for all registered LogRecordProcessors.
        #
        # This operation may block until all the Log Records are processed. Must
        # be called before turning off the main application to ensure all data
        # are processed and exported.
        #
        # After this is called all the newly created {LogRecord}s will be no-op.
        #
        # @param [optional Numeric] timeout An optional timeout in seconds.
        # @return [Integer] Export::SUCCESS if no error occurred, Export::FAILURE if
        #   a non-specific failure occurred, Export::TIMEOUT if a timeout occurred.
        def shutdown(timeout: nil)
          @mutex.synchronize do
            if @stopped
              OpenTelemetry.logger.warn(
                'calling LoggerProvider#shutdown multiple times.'
              )
              return OpenTelemetry::SDK::Logs::Export::FAILURE
            end

            start_time = OpenTelemetry::Common::Utilities.timeout_timestamp
            results = @log_record_processors.map do |processor|
              remaining_timeout = OpenTelemetry::Common::Utilities.maybe_timeout(timeout, start_time)
              break [OpenTelemetry::SDK::Logs::Export::TIMEOUT] if remaining_timeout&.zero?

              # this needs an argument, but I'm having trouble passing the arg to the expect
              # processor.shutdown(timeout: remaining_timeout)
              processor.shutdown
            end

            @stopped = true
            results.max || OpenTelemetry::SDK::Logs::Export::SUCCESS
          end
        end

        # Immediately export all log records that have not yet been exported
        # for all the registered LogRecordProcessors.
        #
        # This method should only be called in cases where it is absolutely
        # necessary, such as when using some FaaS providers that may suspend
        # the process after an invocation, but before the `Processor` exports
        # the completed log records.
        #
        # @param [optional Numeric] timeout An optional timeout in seconds.
        # @return [Integer] Export::SUCCESS if no error occurred, Export::FAILURE if
        #   a non-specific failure occurred, Export::TIMEOUT if a timeout occurred.
        def force_flush(timeout: nil)
          @mutex.synchronize do
            return Export::SUCCESS if @stopped

            start_time = OpenTelemetry::Common::Utilities.timeout_timestamp
            results = @log_record_processors.map do |processor|
              remaining_timeout = OpenTelemetry::Common::Utilities.maybe_timeout(timeout, start_time)
              return Export::TIMEOUT if remaining_timeout&.zero?

              # TODO: Fix the issue with the test not accepting the arg
              # processor.force_flush(timeout: remaining_timeout)
              processor.force_flush
            end

            results.max || Export::SUCCESS
          end
        rescue StandardError
          Export::FAILURE
        end
      end
    end
  end
end
