require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '.format_date' do
    it 'formats date in "Month Day, Year" format' do
      date = Date.new(2024, 1, 15)
      expect(helper.format_date(date)).to eq("January 15, 2024")
    end
  end

  describe '.format_time' do
    it 'formats time in "HH:MM AM/PM" format' do
      time = Time.zone.parse('2024-01-15 14:30:00')
      expect(helper.format_time(time)).to eq("02:30 PM")
    end
  end

  describe '.coerce_numeric' do
    it 'converts numeric strings to float' do
      expect(helper.coerce_numeric('42')).to eq(42.0)
      expect(helper.coerce_numeric('3.14')).to eq(3.14)
    end

    it 'returns numeric values unchanged' do
      expect(helper.coerce_numeric(10)).to eq(10)
      expect(helper.coerce_numeric(2.71)).to eq(2.71)
    end

    it 'raises ArgumentError for non-numeric input' do
      expect { helper.coerce_numeric('abc') }.to raise_error(ArgumentError)
      expect { helper.coerce_numeric(nil) }.to raise_error(ArgumentError)
    end
  end

  describe '.coerce_numeric_or_nil' do
    it 'converts numeric strings to float' do
      expect(helper.coerce_numeric_or_nil('42')).to eq(42.0)
      expect(helper.coerce_numeric_or_nil('3.14')).to eq(3.14)
    end

    it 'returns numeric values unchanged' do
      expect(helper.coerce_numeric_or_nil(10)).to eq(10)
      expect(helper.coerce_numeric_or_nil(2.71)).to eq(2.71)
    end

    it 'returns nil for blank or nil input' do
      expect(helper.coerce_numeric_or_nil(nil)).to be_nil
      expect(helper.coerce_numeric_or_nil('')).to be_nil
      expect(helper.coerce_numeric_or_nil('   ')).to be_nil
    end

    it 'raises ArgumentError for non-numeric input' do
      expect { helper.coerce_numeric_or_nil('abc') }.to raise_error(ArgumentError)
    end
  end

  describe '.parse_time_param' do
    it 'returns nil for nil input' do
      expect(helper.parse_time_param(nil)).to be_nil
    end

    it 'parses valid datetime strings' do
      time_str = '2024-01-01T12:00:00Z'
      expect(helper.parse_time_param(time_str)).to eq(Time.zone.parse(time_str))
    end

    it 'returns Time object unchanged' do
      time_obj = Time.current
      expect(helper.parse_time_param(time_obj.to_s)).to be_within(1.second).of(time_obj)
    end

    it 'returns nil for invalid input' do
      expect(helper.parse_time_param('invalid-date')).to be_nil
      expect(helper.parse_time_param(12345)).to be_nil
    end
  end
end
