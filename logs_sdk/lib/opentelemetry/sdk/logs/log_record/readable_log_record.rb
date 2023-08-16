# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      class ReadableLogRecord < LogRecord
        attr_reader :instrumentation_scope, :resource

        def initialize(**args)
          @span_id = span_id || Context.current
          super
        end
      end
    end
  end
end
