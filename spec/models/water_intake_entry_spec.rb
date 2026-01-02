require 'rails_helper'

RSpec.describe WaterIntakeEntry, type: :model do
  describe "factory" do
    it "creates a valid water intake entry" do
      water_intake_entry = create(:water_intake_entry)
      expect(water_intake_entry).to be_valid
    end
  end

  describe "validations" do
    subject { build(:water_intake_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:cups) }
    it { is_expected.to validate_inclusion_of(:cups).in_range(1..10) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:user_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
