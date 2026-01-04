require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:journal_entry)).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:journaled_at) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
