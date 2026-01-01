require 'rails_helper'

RSpec.describe "Api::V1::CalendarHelpers", type: :request do
  before do
    @signed_in_user = create(:user)
    @valid_headers = auth_headers(user: @signed_in_user)
  end

  describe "GET /week_starting" do
    it "returns http success" do
      get "/api/v1/calendar_helper/week_starting", headers: @valid_headers
      expect(response).to have_http_status(:success)
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :get, -> { "/api/v1/calendar_helper/week_starting" }, :no_token
      it_behaves_like "unauthorized request", :get, -> { "/api/v1/calendar_helper/week_starting" }, :invalid_token
    end
  end
end
