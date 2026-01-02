require 'rails_helper'

RSpec.describe "Api::V1::SleepHoursEntries", type: :request do
  before do
    trio = create_auth_trio
    @user, @session, @token = trio
    @headers = auth_headers(token: @token)
  end

  describe "GET /index" do
    it "returns sleep hours entries in the given date range" do
      create(:sleep_hours_entry, user: @user, date: Date.parse("2025-12-01"))
      create(:sleep_hours_entry, user: @user, date: Date.parse("2025-12-15"))
      create(:sleep_hours_entry, user: @user, date: Date.parse("2026-01-01"))

      get api_v1_sleep_hours_entries_url(start_date: "2025-12-01", end_date: "2025-12-31"), headers: @headers, as: :json
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["records"]).to be_an(Array)
      expect(body["count"]).to eq(2)
    end

    it "returns 400 for invalid date range" do
      get api_v1_sleep_hours_entries_url(start_date: "invalid", end_date: "also_invalid"), headers: @headers, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "GET /show" do
    it "returns the sleep hours entry for a specific date" do
      entry = create(:sleep_hours_entry, user: @user, date: Time.zone.today)
      get api_v1_sleep_hours_entry_url(entry.date), headers: @headers, as: :json
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["date"]).to eq(entry.date.as_json)
      expect(body["hours"]).to eq(entry.hours)
    end

    it "returns 200 when entry not found" do
      get api_v1_sleep_hours_entry_url(Date.parse("1999-01-01")), headers: @headers, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /upsert" do
    it "creates a new sleep hours entry when none exists" do
      payload = { date: Time.zone.today.to_s, hours: 7 }
      post upsert_api_v1_sleep_hours_entries_url, params: payload, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["hours"]).to eq(7)
    end

    it "updates an existing sleep hours entry" do
      entry = create(:sleep_hours_entry, user: @user, date: Time.zone.today, hours: 3)
      payload = { date: entry.date.to_s, hours: 4 }
      post upsert_api_v1_sleep_hours_entries_url, params: payload, headers: @headers, as: :json
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["hours"]).to eq(4)
      expect(entry.reload.hours).to eq(4)
    end

    it "returns 422 for invalid hours" do
      payload = { date: Time.zone.today.to_s, hours: "invalid_hours" }
      post upsert_api_v1_sleep_hours_entries_url, params: payload, headers: @headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end
  end

  describe "authentication" do
    it_behaves_like "unauthorized request", :get, -> { api_v1_sleep_hours_entries_url(start_date: "2025-12-01", end_date: "2025-12-31") }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_sleep_hours_entries_url(start_date: "2025-12-01", end_date: "2025-12-31") }, :invalid_token

    it_behaves_like "unauthorized request", :get, -> { api_v1_sleep_hours_entry_url(Time.zone.today) }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_sleep_hours_entry_url(Time.zone.today) }, :invalid_token
    it_behaves_like "unauthorized request", :post, -> { upsert_api_v1_sleep_hours_entries_url }, :no_token
    it_behaves_like "unauthorized request", :post, -> { upsert_api_v1_sleep_hours_entries_url }, :invalid_token
  end
end
