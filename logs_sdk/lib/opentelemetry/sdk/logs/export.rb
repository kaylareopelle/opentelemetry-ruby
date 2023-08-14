# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # The Export module contains the built-in exporters and log record
      # processors for the OpenTelemetry reference implementation.
      module Export
        # Result codes for the LogRecordExporter#export method and the LogRecordProcessor#force_flush and LogRecordProcessor#shutdown methods.

        # The operation finished successfully.
        SUCCESS = 0

        # The operation finished with an error.
        FAILURE = 1

        # Additional result code for the LogRecordProcessor#force_flush and LogRecordProcessor#shutdown methods.

        # The operation timed out.
        TIMEOUT = 2
      end
    end
  end
end
