# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Logs
    # No-op implementation of the event logger.
    class EventLogger
      EVENT_DOMAIN = 'event.domain'
      EVENT_NAME = 'event.name'

      def initialize(logger:, event_domain:); end

      def create_event(event_name:, log_record:)
        log_record >> Logger
        log_record.attributes.merge(EVENT_DOMAIN: event_name)
      end
    end
  end
end
