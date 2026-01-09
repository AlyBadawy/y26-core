require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:book)).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:rating).only_integer.is_greater_than(0).is_less_than_or_equal_to(5).allow_nil }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
