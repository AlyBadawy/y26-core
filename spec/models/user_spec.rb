
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

    describe "Password Validations" do
      it { is_expected.to validate_length_of(:password).is_at_least(AuthConfiguration.password_min_length) }
      it { is_expected.to validate_length_of(:password).is_at_most(AuthConfiguration.password_max_length) }
    end

    describe "Password Confirmation Validations" do
      context "when password is set" do
        it "validates presence of password_confirmation" do
          user = build(:user, password: "Valid123!", password_confirmation: nil)
          expect(user).not_to be_valid
          expect(user.errors[:password_confirmation]).to include("can't be blank")
        end

        it "is valid when password_confirmation is present" do
          user = build(:user, password: "Valid123!", password_confirmation: "Valid123!")
          expect(user).to be_valid
        end
      end
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
    it { is_expected.to have_many(:weather_entries).dependent(:destroy) }
    it { is_expected.to have_many(:mood_entries).dependent(:destroy) }
    it { is_expected.to have_many(:water_intake_entries).dependent(:destroy) }
    it { is_expected.to have_many(:sleep_hours_entries).dependent(:destroy) }
    it { is_expected.to have_many(:affirmation_entries).dependent(:destroy) }
    it { is_expected.to have_many(:gratitude_entries).dependent(:destroy) }
    it { is_expected.to have_many(:journal_entries).dependent(:destroy) }
  end

  describe "The #generate_reset_password_token! instance method" do
    it "generates and sets a reset password token and timestamp" do
      user = create(:user)
      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_token_created_at).to be_nil

      user.generate_reset_password_token!

      expect(user.reset_password_token).not_to be_nil
      expect(user.reset_password_token_created_at).not_to be_nil
      expect(user.reset_password_token_created_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "The #reset_password_token_valid? instance method" do
    let(:user) { create(:user) }

    context "when reset password token and timestamp are present and not expired" do
      it "returns true" do
        user.generate_reset_password_token!
        expect(user.reset_password_token_valid?).to be true
      end
    end

    context "when reset password token is nil" do
      it "returns false" do
        expect(user.reset_password_token_valid?).to be false
      end
    end

    context "when reset password token timestamp is nil" do
      it "returns false" do
        user.update!(reset_password_token: "some_token", reset_password_token_created_at: nil)
        expect(user.reset_password_token_valid?).to be false
      end
    end
  end

  describe "The #clear_reset_password_token! instance method" do
    it "clears the reset password token and timestamp" do
      user = create(:user)
      user.generate_reset_password_token!

      expect(user.reset_password_token).not_to be_nil
      expect(user.reset_password_token_created_at).not_to be_nil

      user.clear_reset_password_token!

      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_token_created_at).to be_nil
    end
  end

  describe "The #password_expired? instance method" do
    let(:user) { create(:user) }

    context "when password expiration is disabled" do
      before do
        allow(AuthConfiguration).to receive(:password_expires).and_return(false)
      end

      it "returns false" do
        expect(user.password_expired?).to be false
      end
    end

    context "when password expiration is enabled" do
      before do
        allow(AuthConfiguration).to receive_messages(password_expires: true, password_expires_in: 30.days)
      end

      context "when password_changed_at is nil" do
        it "returns true" do
          user.update!(password_changed_at: nil)
          expect(user.password_expired?).to be true
        end
      end

      context "when password_changed_at is set" do
        it "returns true if the password has expired" do
          user.update!(password_changed_at: 31.days.ago)
          expect(user.password_expired?).to be true
        end

        it "returns false if the password has not expired" do
          user.update!(password_changed_at: 10.days.ago)
          expect(user.password_expired?).to be false
        end
      end
    end
  end
end
