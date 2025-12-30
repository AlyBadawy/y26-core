require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  before do
    trio = create_auth_trio
    @signed_in_user, @signed_in_session, @token = trio
    @valid_headers = auth_headers(token: @token)
  end

  describe "GET /index" do
    it "lists all sessions for the current user" do
      get api_v1_sessions_url, headers: @valid_headers, as: :json
      expect(response).to be_successful
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to match_array(%w[records count url])
      records = res_body["records"]
      expect(records).to be_an_instance_of(Array)
      expect(records.first).to include(
        "id",
        "refreshCount",
        "refreshToken",
        "refreshTokenExpiresAt",
        "lastRefreshedAt",
        "revoked"
      )
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :get, -> { api_v1_sessions_url }, :no_token
      it_behaves_like "unauthorized request", :get, -> { api_v1_sessions_url }, :invalid_token
    end
  end

  describe "GET /show" do
    let(:new_session) { create(:session, user: @signed_in_user) }

    it "shows the session for a given ID (get sessions/:id)" do
      get api_v1_session_url(new_session), headers: @valid_headers, as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to include(
        "id",
        "refreshCount",
        "refreshToken",
        "refreshTokenExpiresAt",
        "lastRefreshedAt",
        "revoked"
      )
    end

    it "shows 404 not found for the wrong session ID (get sessions/:id)" do
      get api_v1_session_url("wrong"), headers: @valid_headers, as: :json
      expect(response).not_to be_successful
      expect(response).to have_http_status(:not_found)
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :get, -> { api_v1_session_url(new_session) }, :no_token
      it_behaves_like "unauthorized request", :get, -> { api_v1_session_url(new_session) }, :invalid_token
    end
  end

  describe "POST /create" do
    let(:new_user) { create(:user, password: "MyNewPassword!1", password_confirmation: "MyNewPassword!1") }
    let(:new_session) { create(:session, user: new_user) }
    let(:new_valid_headers) {
      token = AuthEncoder.encode(new_session)
      { "Authorization" => "Bearer #{token}" }
    }
    let(:valid_attributes) {
      { email_address: new_user.email_address, password: "MyNewPassword!1" }
    }

    let(:invalid_attributes) {
      { email_address: new_user.email_address, password: "wrong_password" }
    }

    context "with valid parameters" do
      context "when password is not yet expired" do
        it "signs in the user and returns tokens" do
          headers = { "User-Agent" => "RSpec" }
          post api_v1_sessions_url, params: valid_attributes, headers: headers, as: :json
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(response.body).to include(
            "accessToken",
            "refreshToken",
            "refreshTokenExpiresAt"
          )
        end
      end

      context "when password is expired" do
        it "returns 403 forbidden and instructions to reset password" do
          new_user.update!(password_changed_at: 10.years.ago)
          headers = { "User-Agent" => "RSpec" }
          post api_v1_sessions_url, params: valid_attributes, headers: headers, as: :json
          expect(response).to have_http_status(:forbidden)
          expect(response.content_type).to match(a_string_including("application/json"))
          json_response = JSON.parse(response.body)
          expect(json_response).to include(
            "errors" => ["Password expired"],
            "instructions" => "Please reset your password before logging in."
          )
        end
      end
    end

    context "with invalid parameters" do
      it "returns unauthorized status" do
        headers = { "User-Agent" => "RSpec" }
        post api_v1_sessions_url, params: invalid_attributes, headers: headers, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response.body).to include("error")
      end
    end
  end

  describe "PUT /update" do
    it "refreshes the session" do
      Current.session = @signed_in_session
      expect(Current.session).not_to be_nil
      put api_v1_session_url(@signed_in_session), params: { refresh_token: @signed_in_session.refresh_token }, headers: @valid_headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to match(a_string_including("application/json"))
      expect(response.body).to include(
        "accessToken",
        "refreshToken",
        "refreshTokenExpiresAt"
      )
    end

    it "returns 422 unprocessable entity when session is invalid" do
      Current.session = @signed_in_session
      Current.session.revoke!
      put api_v1_session_url(@signed_in_session), params: { refresh_token: @signed_in_session.refresh_token }, headers: @valid_headers, as: :json
      expect(response).not_to be_successful
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 422 unprocessable entity when refresh_token is invalid" do
      Current.session = @signed_in_session
      expect(Current.session).not_to be_nil
      put api_v1_session_url(@signed_in_session), params: { refresh_token: "invalid" }, headers: @valid_headers, as: :json
      expect(response).not_to be_successful
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /destroy" do
    context "when user is signed in" do
      it "logs out the current user" do
        expect(@signed_in_session).not_to be_revoked
        delete api_v1_session_url(@signed_in_session), headers: @valid_headers, as: :json
        expect(@signed_in_session.reload).to be_revoked
      end

      it "returns 204 no content" do
        Current.session = @signed_in_session
        expect(Current.session).not_to be_nil
        delete api_v1_session_url(@signed_in_session), headers: @valid_headers, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :delete, -> { api_v1_session_url(@signed_in_session) }, :no_token
      it_behaves_like "unauthorized request", :delete, -> { api_v1_session_url(@signed_in_session) }, :invalid_token
    end
  end
end
