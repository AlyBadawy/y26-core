require 'rails_helper'

RSpec.describe "Api::V1::Accounts", type: :request do
    let(:valid_attributes) {
    {
      email_address: "test@example.com",
      password: "passw0rD1!",
      password_confirmation: "passw0rD1!",
      username: "test",
      first_name: "Test",
      last_name: "User",
      phone: "1234567890",
      bio: "Test user",
    }
  }

  let(:invalid_attributes) {
    {
      email_address: "test@example.com",
      password: "password",
      password_confirmation: "invalid",
    }
  }

  let(:expected_keys) {
    %w[id firstName lastName phone username bio createdAt updatedAt url]
  }

   before do
    @signed_in_user = create(:user)
    @valid_headers = auth_headers(user: @signed_in_user)
  end



  describe "GET /create" do
    context "with valid parameters" do
        it "creates a new User" do
          expect {
              post api_v1_accounts_url,
                   params: { user: valid_attributes },
                   as: :json,
                   headers: { "User-Agent" => "Ruby/RSpec" }
          }.to change(User, :count).by(1).and change(Session, :count).by(1)
        end

        it "renders a JSON response with the new user" do
          post api_v1_accounts_url,
               params: { user: valid_attributes },
               as: :json,
               headers: { "User-Agent" => "Ruby/RSpec" }
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including("application/json"))
          res_body = JSON.parse(response.body)

          expect(res_body.keys).to include('accessToken', 'refreshToken', 'refreshTokenExpiresAt', 'user')
        end
      end

      context "with invalid parameters" do
        it "does not create a new User" do
          expect {
            post api_v1_accounts_url,
                 params: { user: invalid_attributes }, as: :json
          }.not_to change(User, :count)
        end

        it "renders a JSON response with errors for the new user" do
          post api_v1_accounts_url,
               params: { user: invalid_attributes }, as: :json
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.content_type).to match(a_string_including("application/json"))
        end
      end
  end

  describe "GET /show" do
    context "when the username is me" do
      it "returns the current user's account details" do
        get api_v1_account_url("me"), headers: @valid_headers, as: :json
        expect(response).to have_http_status(:success)
        res_body = JSON.parse(response.body)
        expect(res_body.keys).to include(*expected_keys)
        expect(res_body["id"]).to eq(@signed_in_user.id)
      end
    end

    context "when the username is another user's username", skip: "TODO: Implement user lookup by username" do
      it "returns the specified user's account details" do
        other_user = create(:user)
        get api_v1_account_url(other_user.username), headers: @valid_headers, as: :json
        expect(response).to have_http_status(:success)
        res_body = JSON.parse(response.body)
        expect(res_body.keys).to include(*expected_keys)
        expect(res_body["id"]).to eq(other_user.id)
      end
    end

    context "when the username does not exist" do
      it "returns a not found error" do
        get api_v1_account_url("non_existent_user"), headers: @valid_headers, as: :json
        expect(response).to have_http_status(:not_found)
        res_body = JSON.parse(response.body)
        expect(res_body["errors"]).to include("User not found")
      end
    end
  end

  describe "GET /update", skip: "TODO"  do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          first_name: "Updated",
          last_name: "User",
          phone: "0987654321",
          bio: "Updated bio",
        }
      }

      it "updates the requested user" do
        put api_v1_account_url("me"),
            params: { user: new_attributes, current_password: valid_attributes[:password] },
            headers: @valid_headers,
            as: :json
        @signed_in_user.reload
        expect(@signed_in_user.first_name).to eq("Updated")
        expect(@signed_in_user.last_name).to eq("User")
        expect(@signed_in_user.phone).to eq("0987654321")
        expect(@signed_in_user.bio).to eq("Updated bio")
      end

      it "renders a JSON response with the user" do
        put api_v1_account_url("me"),
            params: { user: new_attributes, current_password: valid_attributes[:password] },
            headers: @valid_headers,
            as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
        res_body = JSON.parse(response.body)
        expect(res_body.keys).to include(*expected_keys)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the user" do
        put api_v1_account_url("me"),
            params: { user: invalid_attributes, current_password: valid_attributes[:password] },
            headers: @valid_headers,
            as: :json
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with incorrect current password" do
      it "renders a JSON response with an authentication error" do
        put api_v1_account_url("me"),
            params: { user: valid_attributes, current_password: "wrongpassword" },
            headers: @valid_headers,
            as: :json
        expect(response).to have_http_status(:unprocessable_content)
        res_body = JSON.parse(response.body)
        expect(res_body["errors"]).to include("Current password is incorrect")
      end
    end
  end

  describe "GET /destroy", skip: "TODO"  do
    context "with correct current password" do
      it "deletes the user's account" do
        expect {
          delete api_v1_account_url("me"),
                 params: { current_password: valid_attributes[:password] },
                 headers: @valid_headers,
                 as: :json
        }.to change(User, :count).by(-1)
      end

      it "renders a JSON response confirming deletion" do
        delete api_v1_account_url("me"),
               params: { current_password: valid_attributes[:password] },
               headers: @valid_headers,
               as: :json
        expect(response).to have_http_status(:ok)
        res_body = JSON.parse(response.body)
        expect(res_body["message"]).to eq("Account deleted successfully")
      end
    end

    context "with incorrect current password" do
      it "does not delete the user's account" do
        expect {
          delete api_v1_account_url("me"),
                 params: { current_password: "wrongpassword" },
                 headers: @valid_headers,
                 as: :json
        }.not_to change(User, :count)
      end

      it "renders a JSON response with an authentication error" do
        delete api_v1_account_url("me"),
               params: { current_password: "wrongpassword" },
               headers: @valid_headers,
               as: :json
        expect(response).to have_http_status(:unprocessable_content)
        res_body = JSON.parse(response.body)
        expect(res_body["errors"]).to include("Current password is incorrect")
      end
    end
  end
end
