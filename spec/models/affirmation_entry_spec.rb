require 'rails_helper'

RSpec.describe AffirmationEntry, type: :model do
  describe "factory" do
    it "creates a valid affirmation entry" do
      affirmation_entry = create(:affirmation_entry)
      expect(affirmation_entry).to be_valid
    end
  end

  describe "validations" do
    subject { build(:affirmation_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:content) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
