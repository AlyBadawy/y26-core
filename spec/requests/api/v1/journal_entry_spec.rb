require 'rails_helper'

RSpec.describe "Api::V1::JournalEntries", type: :request do
  before do
    trio = create_auth_trio
    @user, @session, @token = trio
    @headers = auth_headers(token: @token)
  end

  describe "GET /index" do
    it "returns entries in the date range ordered ascending" do
      create(:journal_entry, user: @user, journaled_at: Date.parse("2025-12-30"))
      create(:journal_entry, user: @user, journaled_at: Date.parse("2025-12-31"))
      create(:journal_entry, user: @user, journaled_at: Date.parse("2026-01-05"))

      get api_v1_journal_entries_url, params: { start_date: "2025-12-30", end_date: "2026-01-01" }, headers: @headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["count"]).to eq(2)
      dates = body["records"].map { |r| Date.parse(r["journaledAt"]) }
      expect(dates).to eq(dates.sort)
    end

    it "returns bad_request for invalid date params" do
      get api_v1_journal_entries_url, params: { start_date: "bad", end_date: "also_bad" }, headers: @headers
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Invalid or missing date range")
    end
  end

  describe "GET /show" do
    it "returns the requested journal entry" do
      entry = create(:journal_entry, user: @user)
      get api_v1_journal_entry_url(entry.id), headers: @headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(entry.id)
      expect(body["content"]).to eq(entry.content)
    end
  end

  describe "POST /create" do
    let(:valid_params) { { journal_entry: { title: "Test journal", content: "My journal entry", journaled_at: Time.zone.now.iso8601 } } }
    let(:invalid_params) { { journal_entry: { title: "", content: "" } } }

    it "creates a journal entry with valid params" do
      expect {
        post api_v1_journal_entries_url, params: valid_params, headers: @headers, as: :json
      }.to change(JournalEntry, :count).by(1)
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["content"]).to eq("My journal entry")
    end

    it "does not create a journal entry with invalid params" do
      expect {
        post api_v1_journal_entries_url, params: invalid_params, headers: @headers, as: :json
      }.not_to change(JournalEntry, :count)
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Title can't be blank", "Journaled at can't be blank")
    end
  end

  describe "PATCH /update" do
    let(:journal_entry) { create(:journal_entry, user: @user, content: "Old content") }
    let(:valid_params) { { journal_entry: { content: "Updated content" } } }
    let(:invalid_params) { { journal_entry: { title: "" } } }

    it "updates the journal entry with valid params" do
      patch api_v1_journal_entry_url(journal_entry.id), params: valid_params, headers: @headers, as: :json
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["content"]).to eq("Updated content")
      expect(journal_entry.reload.content).to eq("Updated content")
    end

    it "does not update the journal entry with invalid params" do
      patch api_v1_journal_entry_url(journal_entry.id), params: invalid_params, headers: @headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Title can't be blank")
      expect(journal_entry.reload.title).not_to be_nil
    end
  end

  describe "DELETE /destroy" do
    it "deletes the journal entry" do
      entry = create(:journal_entry, user: @user)
      expect {
        delete api_v1_journal_entry_url(entry.id), headers: @headers, as: :json
      }.to change(JournalEntry, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "authentication" do
    it_behaves_like "unauthorized request", :get, -> { api_v1_journal_entries_url(start_date: "2025-12-01", end_date: "2025-12-31") }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_journal_entries_url(start_date: "2025-12-01", end_date: "2025-12-31") }, :invalid_token

    it_behaves_like "unauthorized request", :get, -> { api_v1_journal_entry_url(1) }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_journal_entry_url(1) }, :invalid_token
    it_behaves_like "unauthorized request", :post, -> { api_v1_journal_entries_url }, :no_token
    it_behaves_like "unauthorized request", :post, -> { api_v1_journal_entries_url }, :invalid_token

    it_behaves_like "unauthorized request", :put, -> { api_v1_journal_entry_url(1) }, :no_token
    it_behaves_like "unauthorized request", :put, -> { api_v1_journal_entry_url(1) }, :invalid_token
    it_behaves_like "unauthorized request", :delete, -> { api_v1_journal_entry_url(1) }, :no_token
    it_behaves_like "unauthorized request", :delete, -> { api_v1_journal_entry_url(1) }, :invalid_token
  end
end
