# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module SDK
    module Metrics
      module State
        # @api private
        #
        # The MetricStream class provides SDK internal functionality that is not a part of the
        # public API.
        class MetricStream
          attr_reader :name, :description, :unit, :instrument_kind, :instrumentation_scope, :data_points

          def initialize(
            name,
            description,
            unit,
            instrument_kind,
            meter_provider,
            instrumentation_scope,
            aggregation
          )
            @name = name
            @description = description
            @unit = unit
            @instrument_kind = instrument_kind
            @meter_provider  = meter_provider
            @instrumentation_scope = instrumentation_scope
            @default_aggregation = aggregation
            @data_points = {}

            @mutex = Mutex.new
          end

          def collect(start_time, end_time)
            metric_data      = Array.new
            registred_views  = find_registered_view

            if registred_views.empty?
              metric_data << aggregate_metric_data(start_time, end_time)
            else
              registred_views.each { |view| metric_data << aggregate_metric_data(start_time, end_time, aggregation: view.aggregation) }
            end

            metric_data
          end

          def update(value, attributes)
            registred_views = find_registered_view
            if registred_views.empty?
              @mutex.synchronize { @default_aggregation.update(value, attributes, @data_points) }
            else
              registred_views.each do |view|
                @mutex.synchronize {
                  attributes = attributes || {}
                  attributes.merge!(view.attribute_keys)
                  view.aggregation.update(value, attributes, @data_points) 
                }
              end
            end
          end

          def aggregate_metric_data(start_time, end_time, aggregation: nil)
            aggregator = aggregation || @default_aggregation
            MetricData.new(
              @name,
              @description,
              @unit,
              @instrument_kind,
              @meter_provider.resource,
              @instrumentation_scope,
              aggregator.collect(start_time, end_time, @data_points),
              aggregator.aggregation_temporality,
              start_time,
              end_time
            )
          end

          def find_registered_view
            registred_views = Array.new
            @meter_provider.registered_views.each { |view| registred_views << view if view.match_instrument(self) }
            registred_views
          end
          
          def to_s
            instrument_info = String.new
            instrument_info << "name=#{@name}"
            instrument_info << " description=#{@description}" if @description
            instrument_info << " unit=#{@unit}" if @unit
            @data_points.map do |attributes, value|
              metric_stream_string = String.new
              metric_stream_string << instrument_info
              metric_stream_string << " attributes=#{attributes}" if attributes
              metric_stream_string << " #{value}"
              metric_stream_string
            end.join("\n")
          end
        end
      end
    end
  end
end
