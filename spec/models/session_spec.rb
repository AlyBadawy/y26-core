require "rails_helper"
RSpec.describe Session, type: :model do
  let(:user) { create(:user) }
  let(:session) { create(:session, user: user) }

  describe "factory" do
    it "has a valid factory" do
      expect(build(:session)).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:ip_address) }
    it { is_expected.to validate_presence_of(:user_agent) }
    it { is_expected.to validate_presence_of(:refresh_token) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "The #revoke! instance method" do
    it "sets revoked to true" do
      session.revoke!
      expect(session.reload.revoked).to be true
    end
  end

  describe "The #is_valid_session? instance method" do
    context "when the session is not revoked and not expired" do
      it "returns true" do
        expect(session.is_valid_session?).to be true
      end
    end

    context "when the session is revoked" do
      it "returns false" do
        session.revoke!
        expect(session.is_valid_session?).to be false
      end
    end

    context "when the session is expired" do
      it "returns false" do
        session.update!(refresh_token_expires_at: 1.minute.ago)
        expect(session.is_valid_session?).to be false
      end
    end
  end

  describe "The #refresh! instance method" do
    context "when the session is valid" do
      it "does not raise an error" do
        expect { session.refresh! }.not_to raise_error
      end

      it "updates the refresh_token and refresh_token_expires_at" do
        expect {
          session.refresh!
        }.to change { session.reload.refresh_token }.and change { session.reload.refresh_token_expires_at }.to (be_within(1.second).of(1.week.from_now))
      end

      it "increments the refresh_count" do
        expect {
          session.refresh!
        }.to change { session.reload.refresh_count }.by(1)
      end

      it "updates the last_refreshed_at" do
        expect {
          session.refresh!
        }.to change { session.reload.last_refreshed_at }.to be_within(1.second).of(Time.current)
      end

      it "does not change the revoked status" do
        expect {
          session.refresh!
        }.not_to change { session.reload.revoked }
      end

      it "does not change the user agent" do
        expect {
          session.refresh!
        }.not_to change { session.reload.user_agent }
      end

      it "does not change the IP address" do
        expect {
          session.refresh!
        }.not_to change { session.reload.ip_address }
      end

      it "does not change the user" do
        expect {
          session.refresh!
        }.not_to change { session.reload.user }
      end
    end

    context "when the session is revoked" do
      before { session.revoke! }

      it "raises an error" do
        expect { session.refresh! }.to raise_error("Session token is revoked")
      end
    end

    context "when the session is expired" do
      before { session.update!(refresh_token_expires_at: 1.minute.ago) }

      it "raises an error" do
        expect { session.refresh! }.to raise_error("Session token is expired")
      end
    end
  end

  describe "The #is_valid_session_request? instance method" do
    let(:mock_request) { instance_double(ActionDispatch::Request, ip: session.ip_address, user_agent: session.user_agent) }

    context "when the session is valid and request matches" do
      it "returns true" do
        expect(session.is_valid_session_request?(mock_request)).to be true
      end
    end

    context "when the session is invalid" do
      before { session.revoke! }

      it "returns false" do
        expect(session.is_valid_session_request?(mock_request)).to be false
      end
    end

    context "when the request IP does not match" do
      let(:mock_request) { instance_double(ActionDispatch::Request, ip: "different_ip", user_agent: session.user_agent) }

      it "returns false" do
        expect(session.is_valid_session_request?(mock_request)).to be false
      end
    end

    context "when the request user agent does not match" do
      let(:mock_request) { instance_double(ActionDispatch::Request, ip: session.ip_address, user_agent: "different_user_agent") }

      it "returns false" do
        expect(session.is_valid_session_request?(mock_request)).to be false
      end
    end
  end
end
