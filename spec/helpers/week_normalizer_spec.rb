require "rails_helper"

RSpec.describe WeekNormalizer do
  describe ".start_of_week" do
    it "uses Date.current when no date is provided" do
      allow(Date).to receive(:current).and_return(Date.new(2025, 12, 24))

      expect(described_class.start_of_week).to eq(Date.new(2025, 12, 24).beginning_of_week(:monday))
    end

    it "returns the beginning of the week (Monday) for a given Date" do
      date = Date.new(2023, 11, 15) # a Wednesday

      expect(described_class.start_of_week(date)).to eq(date.beginning_of_week(:monday))
    end

    it "works with Time objects (returns a Time beginning_of_week)" do
      time = Time.zone.local(2024, 1, 10, 13, 0, 0) # a Wednesday

      expect(described_class.start_of_week(time)).to eq(time.beginning_of_week(:monday))
    end
  end
end
