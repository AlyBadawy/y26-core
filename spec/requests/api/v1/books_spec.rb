require 'rails_helper'

RSpec.describe "Api::V1::Books", type: :request do
  before do
    trio = create_auth_trio
    @user, @session, @token = trio
    @headers = auth_headers(token: @token)
  end

  describe "GET /index" do
    it "returns a successful response" do
      create_list(:book, 3, user: @user)

      get api_v1_books_path, headers: @headers, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["records"]).to be_an(Array)
      expect(body["count"]).to eq(3)
    end

    it "returns only books for the authenticated user" do
      other_user = create(:user)
      create_list(:book, 2, user: other_user)
      create_list(:book, 4, user: @user)

      get api_v1_books_path, headers: @headers, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["records"].length).to eq(4)
    end
  end

  describe "GET /show" do
    it "returns the specified book" do
      book = create(:book, user: @user)

      get api_v1_book_path(book), headers: @headers, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(book.id)
      expect(body["title"]).to eq(book.title)
    end

    it "returns 404 for a book that does not belong to the user" do
      other_user = create(:user)
      book = create(:book, user: other_user)

      get api_v1_book_path(book), headers: @headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    it "creates a new book" do
      book_params = {
        book: {
          title: "New Book",
          author: "Author Name",
          genre: "Fiction",
          rating: 4,
          started_on: "2026-01-01",
          finished_on: "2026-01-10",
          status: "read",
          notes: "Some notes about the book",
        },
      }
      post api_v1_books_path, params: book_params, headers: @headers, as: :json
      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("New Book")
      expect(body["author"]).to eq("Author Name")
    end

    it "returns 422 for invalid book data" do
      book_params = {
        book: {
          title: "", # Invalid title
          author: "Author Name",
          status: "read",
        },
      }
      post api_v1_books_path, params: book_params, headers: @headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Title can't be blank")
    end
  end

  describe "PUT /update" do
    it "updates an existing book" do
      book = create(:book, user: @user)
      update_params = {
        book: {
          title: "Updated Title",
          rating: 5,
        },
      }
      put api_v1_book_path(book), params: update_params, headers: @headers, as: :json
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Updated Title")
      expect(body["rating"]).to eq(5)
    end

    it "returns 422 for invalid update data" do
      book = create(:book, user: @user)
      update_params = {
        book: {
          title: "", # Invalid title
        },
      }
      put api_v1_book_path(book), params: update_params, headers: @headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Title can't be blank")
    end
  end

  describe "DELETE /destroy" do
    it "deletes an existing book" do
      book = create(:book, user: @user)

      delete api_v1_book_path(book), headers: @headers, as: :json

      expect(response).to have_http_status(:no_content)
      expect(Book.find_by(id: book.id)).to be_nil
    end

    it "returns 404 when trying to delete a book that does not belong to the user" do
      other_user = create(:user)
      book = create(:book, user: other_user)

      delete api_v1_book_path(book), headers: @headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "authentication" do
    it_behaves_like "unauthorized request", :get, -> { api_v1_books_path }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_books_path }, :invalid_token

    it_behaves_like "unauthorized request", :get, -> { api_v1_book_path(SecureRandom.uuid) }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_book_path(SecureRandom.uuid) }, :invalid_token

    it_behaves_like "unauthorized request", :post, -> { api_v1_books_path }, :no_token
    it_behaves_like "unauthorized request", :post, -> { api_v1_books_path }, :invalid_token

    it_behaves_like "unauthorized request", :put, -> { api_v1_book_path(SecureRandom.uuid) }, :no_token
    it_behaves_like "unauthorized request", :put, -> { api_v1_book_path(SecureRandom.uuid) }, :invalid_token

    it_behaves_like "unauthorized request", :delete, -> { api_v1_book_path(SecureRandom.uuid) }, :no_token
    it_behaves_like "unauthorized request", :delete, -> { api_v1_book_path(SecureRandom.uuid) }, :invalid_token
  end
end
