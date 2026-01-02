require 'rails_helper'

RSpec.describe MoodEntry, type: :model do
  describe "factory" do
    it "creates a valid mood entry" do
      mood_entry = create(:mood_entry)
      expect(mood_entry).to be_valid
    end
  end

  describe "validations" do
    subject { build(:mood_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_range(1..5) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:user_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
