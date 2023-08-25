# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # Class with constants representing the numerical value of the log severity
    # as defined in the OpenTelemetry specification.
    class SeverityNumber
      # TRACE: A fine-grained debugging event. Typically disabled in
      # default configurations.
      TRACE = 1
      TRACE2 = 2
      TRACE3 = 3
      TRACE4 = 4

      # DEBUG: Used for debugging events.
      DEBUG = 5
      DEBUG2 = 6
      DEBUG3 = 7
      DEBUG4 = 8

      # INFO: An informational event. Indicates that an event happened.
      INFO = 9
      INFO2 = 10
      INFO3 = 11
      INFO4 = 12

      # WARN: A warning event. Not an error but is likely more important than an
      # informational event.
      WARN = 13
      WARN2 = 14
      WARN3 = 15
      WARN4 = 16

      # ERROR: An error event. Something went wrong.
      ERROR = 17
      ERROR2 = 18
      ERROR3 = 19
      ERROR4 = 20

      # FATAL: A fatal error such as application or system crash.
      FATAL = 21
      FATAL2 = 22
      FATAL3 = 23
      FATAL4 = 24
    end
  end
end
