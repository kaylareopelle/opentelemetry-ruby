# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require_relative 'logs/version'
require_relative 'logs/logger'
require_relative 'logs/logger_provider'
require_relative 'logs/log_record_processor'
require_relative 'logs/export'
require_relative 'logs/read_write_log_record'
require_relative 'logs/readable_log_record'

module OpenTelemetry
  module SDK
    # The Logs module contains the OpenTelemetry logs reference
    # implementation.
    module Logs
    end
  end
end
