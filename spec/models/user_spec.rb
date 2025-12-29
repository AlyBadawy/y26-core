require 'rails_helper'

RSpec.describe User, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:user)).to be_valid
    end
  end

  describe "validations" do
    subject { build(:user) }

    describe "Email Address Validations" do
      it { is_expected.to validate_presence_of(:email_address) }
      it { is_expected.to validate_length_of(:email_address).is_at_least(5) }
      it { is_expected.to validate_length_of(:email_address).is_at_most(255) }
      it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    end

    describe "Username Validations" do
      it { is_expected.to validate_presence_of(:username) }

      it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
      it { is_expected.to validate_length_of(:username).is_at_most(20) }
    end

    describe "Username Format Validations" do
      it { is_expected.to allow_value("valid_username").for(:username) }
      it { is_expected.to allow_value("valid.username").for(:username) }
      it { is_expected.to allow_value("valid_username123").for(:username) }
      it { is_expected.to allow_value("valid_username_123").for(:username) }
      it { is_expected.to allow_value("valid.username_123").for(:username) }
      it { is_expected.not_to allow_value("123username").for(:username) }
      it { is_expected.not_to allow_value("valid__username").for(:username) }
      it { is_expected.not_to allow_value("valid..username").for(:username) }
      it { is_expected.not_to allow_value("valid__username.").for(:username) }
      it { is_expected.not_to allow_value("valid.username__").for(:username) }
      it { is_expected.not_to allow_value("valid.username__123").for(:username) }
      it { is_expected.not_to allow_value("valid.username__123_").for(:username) }
      it { is_expected.not_to allow_value("valid.username__123.").for(:username) }
      it { is_expected.not_to allow_value("valid.username__123_456").for(:username) }
      it { is_expected.not_to allow_value("valid.username__123_456.").for(:username) }
      it { is_expected.not_to allow_value("valid.username__123_456_").for(:username) }
      it { is_expected.not_to allow_value("valid.username__123_456_789").for(:username) }
    end
  end

  describe "normalizations" do
    it "normalizes email address" do
      user = build(:user)
      user.email_address = " Test@Example.COM "
      user.valid?
      expect(user.email_address).to eq("test@example.com")
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end
end
