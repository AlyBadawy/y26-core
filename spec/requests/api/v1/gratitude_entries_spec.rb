require 'rails_helper'

RSpec.describe "Api::V1::GratitudeEntries", type: :request do
  before do
    trio = create_auth_trio
    @user, @session, @token = trio
    @headers = auth_headers(token: @token)
  end

  describe "GET /index" do
    it "returns entries in the date range ordered ascending" do
      create(:gratitude_entry, user: @user, date: Date.parse("2025-12-30"))
      create(:gratitude_entry, user: @user, date: Date.parse("2025-12-31"))
      create(:gratitude_entry, user: @user, date: Date.parse("2026-01-05"))

      get api_v1_gratitude_entries_url, params: { start_date: "2025-12-30", end_date: "2026-01-01" }, headers: @headers.except("Content-Type")
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["count"]).to eq(2)
      dates = body["records"].map { |r| Date.parse(r["date"]) }
      expect(dates).to eq(dates.sort)
    end

    it "returns bad_request for invalid date params" do
      get api_v1_gratitude_entries_url, params: { start_date: "bad", end_date: "also_bad" }, headers: @headers.except("Content-Type")
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Invalid or missing date range")
    end
  end

  describe "GET /show" do
    it "returns the requested gratitude entry" do
      entry = create(:gratitude_entry, user: @user)
      get api_v1_gratitude_entry_url(entry.id), headers: @headers.except("Content-Type")
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(entry.id)
      expect(body["content"]).to eq(entry.content)
    end
  end

  describe "POST /create" do
    let(:valid_params) { { gratitude_entry: { date: Time.zone.today.to_s, content: "I am grateful" } } }
    let(:invalid_params) { { gratitude_entry: { date: "", content: "" } } }

    it "creates a gratitude entry with valid params" do
      expect {
        post api_v1_gratitude_entries_url, params: valid_params, headers: @headers, as: :json
      }.to change(GratitudeEntry, :count).by(1)
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["content"]).to eq("I am grateful")
    end

    it "returns errors for invalid params" do
      post api_v1_gratitude_entries_url, params: invalid_params, headers: @headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end
  end

  describe "PUT /update" do
    it "updates when params are valid" do
      entry = create(:gratitude_entry, user: @user, content: "old")
      put api_v1_gratitude_entry_url(entry.id), params: { gratitude_entry: { content: "new" } }, headers: @headers, as: :json
      expect(response).to have_http_status(:ok)
      entry.reload
      expect(entry.content).to eq("new")
    end

    it "returns errors for invalid update params" do
      entry = create(:gratitude_entry, user: @user)
      put api_v1_gratitude_entry_url(entry.id), params: { gratitude_entry: { date: "" } }, headers: @headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end
  end

  describe "DELETE /destroy" do
    it "deletes the entry" do
      entry = create(:gratitude_entry, user: @user)
      expect {
        delete api_v1_gratitude_entry_url(entry.id), headers: @headers, as: :json
      }.to change(GratitudeEntry, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
