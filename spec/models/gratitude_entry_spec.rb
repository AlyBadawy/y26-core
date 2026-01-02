require 'rails_helper'

RSpec.describe GratitudeEntry, type: :model do
  describe "factory" do
    it "creates a valid gratitude entry" do
      gratitude_entry = create(:gratitude_entry)
      expect(gratitude_entry).to be_valid
    end
  end

  describe "validations" do
    subject { build(:gratitude_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:content) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
