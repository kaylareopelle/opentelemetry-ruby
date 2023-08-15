# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # Presently no-op LogRecordProcessor
      class LogRecordProcessor
        def shutdown(timeout: nil)
          # TODO: implement
        end

        def force_flush(timeout: nil)
          # TODO: implement
        end
      end
    end
  end
end
