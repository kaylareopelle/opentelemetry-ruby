# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

require 'test_helper'

describe OpenTelemetry::SDK::Logs::Export::SimpleLogRecordProcessor do
  describe '#initialize' do
    it 'raises an error if exporter is invalid' do
    end
  end

  describe '#emit' do
    it 'does not emit if stopped' do
    end

    it 'does not emit unless sampled' do
    end

    it 'converts the log records to LogRecordData when sampled' do
    end

    it 'catches and logs exporter errors' do
    end

    it 'calls export on the log records' do
    end
  end

  describe '#force_flush' do
    it 'does not attempt to flush if stopped' do
    end

    it 'returns success when the exporter cannot be found' do
    end

    it 'calls #force_flush on the exporter' do
    end
  end

  describe '#shutdown' do
    it 'does not attempt to shutdown if stopped' do
    end

    it 'returns success when the exporter cannot be found' do
    end

    it 'sets stopped to true when the exporter cannot be found' do
    end

    it 'calls shutdown on the exporter' do
    end

    it 'sets stopped to true after calling shutdown on the exporter' do
    end
  end
end
