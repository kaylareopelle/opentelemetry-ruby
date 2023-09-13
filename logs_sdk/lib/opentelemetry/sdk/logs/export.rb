# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0
module OpenTelemetry
  module SDK
    module Logs
      # The Export module contains result codes for exporters
      module Export
        # The operation finished successfully.
        SUCCESS = 0

        # The operation finished with an error.
        FAILURE = 1

        # The operation timed out.
        TIMEOUT = 2
      end
    end
  end
end

require_relative 'export/simple_log_record_processor'
require_relative 'export/batch_log_record_processor'
require_relative 'export/log_record_exporter'
require_relative 'export/console_log_record_exporter'
require_relative 'export/in_memory_log_record_exporter'
