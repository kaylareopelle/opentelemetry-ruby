# frozen_string_literal: true

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem "opentelemetry-api"
  gem "opentelemetry-common"
  gem "opentelemetry-sdk"

  gem 'opentelemetry-metrics-api', path: '../../metrics_api'
  gem 'opentelemetry-metrics-sdk', path: '../../metrics_sdk'
  gem 'opentelemetry-exporter-otlp-metrics', path: '../../exporter/otlp-metrics'

end

require 'opentelemetry/sdk'
require 'opentelemetry-metrics-sdk'
require 'opentelemetry-exporter-otlp-metrics'

ENV['OTEL_EXPORTER_OTLP_METRICS_ENDPOINT'] = 'http://host.docker.internal:4318/v1/metrics'
OpenTelemetry::SDK.configure

otlp_metric_exporter = OpenTelemetry::Exporter::OTLP::Metrics::MetricsExporter.new

OpenTelemetry.meter_provider.add_metric_reader(otlp_metric_exporter)
OpenTelemetry.meter_provider.add_metric_reader(OpenTelemetry::SDK::Metrics::Export::ConsoleMetricPullExporter.new)

meter = OpenTelemetry.meter_provider.meter("SAMPLE_METER_NAME")

histogram = meter.create_histogram('histogram', unit: 'smidgen', description: 'desscription')

histogram.record(123, attributes: {'foo' => 'bar'})

OpenTelemetry.meter_provider.metric_readers.each(&:pull)
OpenTelemetry.meter_provider.shutdown
