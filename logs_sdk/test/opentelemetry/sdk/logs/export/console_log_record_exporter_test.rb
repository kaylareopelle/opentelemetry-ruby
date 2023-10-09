# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

# rubocop:disable Lint/ConstantDefinitionInBlock
describe OpenTelemetry::SDK::Logs::Export::ConsoleLogRecordExporter do
  Export = OpenTelemetry::SDK::Logs::Export

  let(:captured_stdout)  { StringIO.new }
  let(:log_record_data1) { OpenTelemetry::SDK::Logs::LogRecordData.new({ body: 'body1' }) }
  let(:log_record_data2) { OpenTelemetry::SDK::Logs::LogRecordData.new({ body: 'body2' }) }
  let(:log_records)      { [log_record_data1, log_record_data2] }
  let(:exporter)         { Export::ConsoleLogRecordExporter.new }

  before do
    @original_stdout = $stdout
    $stdout = captured_stdout
  end

  after do
    $stdout = @original_stdout
  end

  it 'accepts an Array of LogRecordData as arg to #export and succeeds' do
    assert_equal(Export::SUCCESS, exporter.export(log_records))
  end

  it 'accepts an Enumerable of LogRecordData as arg to #export and succeeds' do
    enumerable = Struct.new(:log_record0, :log_record1).new(log_records[0], log_records[1])

    assert_equal(Export::SUCCESS, exporter.export(enumerable))
  end

  it 'outputs to console (stdout)' do
    exporter.export(log_records)

    assert_match(/#<struct OpenTelemetry::SDK::Logs::LogRecordData/, captured_stdout.string)
  end

  it 'accepts calls to #force_flush' do
    exporter.force_flush
  end

  it 'accepts calls to #shutdown' do
    exporter.shutdown
  end

  it 'fails to export after shutdown' do
    exporter.shutdown

    assert_equal(Export::FAILURE, exporter.export(log_records))
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock
