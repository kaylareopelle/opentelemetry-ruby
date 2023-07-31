# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'opentelemetry'
require_relative 'logs/log_record'
require_relative 'logs/logger'
require_relative 'logs/logger_provider'

module OpenTelemetry
  # OpenTelemetry Logs API
  module Logs
    extend self

    # Sets a global LoggerProvider
    # @api public
    def logger_provider
      @logger_provider ||= OpenTelemetry::Logs::LoggerProvider.new
    end
  end
end
