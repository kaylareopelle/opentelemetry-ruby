# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Logs
      # LogRecordData is a Struct containing {LogRecord} data for export.
      LogRecordData = Struct.new(:timestamp,                 # optional Integer nanoseconds since Epoch
                                 :observed_timestamp,        # Integer nanoseconds since Epoch
                                 :trace_id,                  # optional String (16-byte binary)
                                 :span_id,                   # optional String (8 byte binary)
                                 :trace_flags,               # optional Integer (8-bit byte of bit flags)
                                 :severity_text,             # optional String
                                 :severity_number,           # optional Integer
                                 :body,                      # optional String, Numeric, Boolean, Array<String, Numeric,
                                                             #   Boolean>, Hash{String => String, Numeric, Boolean, Array<String,
                                                             #   Numeric, Boolean>}
                                 :resource,                  # optional OpenTelemetry::SDK::Resources::Resource
                                 :instrumentation_scope,     # OpenTelemetry::SDK::InstrumentationScope
                                 :attributes) do             # optional Hash{String => String, Numeric, Boolean, Array<String, Numeric, Boolean>}
                              # Returns the lowercase [hex encoded](https://tools.ietf.org/html/rfc4648#section-8) span ID.
                              #
                              # @return [String] A 16-hex-character lowercase string.
                              def hex_span_id
                                span_id.unpack1('H*')
                              end

                              # Returns the lowercase [hex encoded](https://tools.ietf.org/html/rfc4648#section-8) trace ID.
                              #
                              # @return [String] A 32-hex-character lowercase string.
                              def hex_trace_id
                                trace_id.unpack1('H*')
                              end
                            end
    end
  end
end
