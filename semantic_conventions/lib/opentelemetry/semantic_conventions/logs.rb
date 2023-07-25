# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SemanticConventions
    module Logs
      # The name identifies the event
      EVENT_NAME = 'event.name'

      # The domain identifies the context in which an event happened. An event name is unique only within a domain
      # @note An `event.name` is supposed to be unique only in the context of an
      #  `event.domain`, so this allows for two events in different domains to
      #  have same `event.name`, yet be unrelated events
      EVENT_DOMAIN = 'event.domain'

    end
  end
end