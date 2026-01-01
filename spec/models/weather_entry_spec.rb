require 'rails_helper'

RSpec.describe WeatherEntry, type: :model do
  describe "factory" do
    it "creates a valid weather" do
      weather_entry = create(:weather_entry)
      expect(weather_entry).to be_valid
    end
  end

  describe "validations" do
    subject { build(:weather_entry) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:user_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
