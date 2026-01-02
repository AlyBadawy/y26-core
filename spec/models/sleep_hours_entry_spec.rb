require 'rails_helper'

RSpec.describe SleepHoursEntry, type: :model do
  describe "factory" do
    it "creates a valid sleep hours entry" do
      sleep_hours_entry = create(:sleep_hours_entry)
      expect(sleep_hours_entry).to be_valid
    end
  end

  describe "validations" do
    subject { build(:sleep_hours_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:hours) }
    it { is_expected.to validate_inclusion_of(:hours).in_range(0..10) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
