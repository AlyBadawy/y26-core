require 'rails_helper'

RSpec.describe "Api::V1::Movies", type: :request do
  before do
    trio = create_auth_trio
    @user, @session, @token = trio
    @headers = auth_headers(token: @token)
  end

  describe "GET /index" do
    it "returns a successful response" do
      create_list(:movie, 3, user: @user)

      get api_v1_movies_path, headers: @headers, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["records"]).to be_an(Array)
      expect(body["count"]).to eq(3)
    end

    it "returns only movies for the authenticated user" do
      other_user = create(:user)
      create_list(:movie, 2, user: other_user)
      create_list(:movie, 4, user: @user)

      get api_v1_movies_path, headers: @headers, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["records"].length).to eq(4)
    end
  end

  describe "GET /show" do
    it "returns the specified movie" do
      movie = create(:movie, user: @user)

      get api_v1_movie_path(movie), headers: @headers, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(movie.id)
      expect(body["title"]).to eq(movie.title)
    end

    it "returns 404 for a movie that does not belong to the user" do
      other_user = create(:user)
      movie = create(:movie, user: other_user)

      get api_v1_movie_path(movie), headers: @headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    it "creates a new movie" do
      movie_params = {
        title: "Inception",
        genre: "Sci-Fi",
        rating: 5,
        watched_on: "2023-01-01",
        status: "watched",
        notes: "Great movie!",
      }

      post api_v1_movies_path, params: { movie: movie_params }, headers: @headers, as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Inception")
      expect(body["genre"]).to eq("Sci-Fi")
      expect(body["rating"]).to eq(5)
      expect(body["status"]).to eq("watched")
    end

    it "returns 422 for invalid movie data" do
      movie_params = {
        title: "", # Invalid title
        rating: 10, # Invalid rating
      }

      post api_v1_movies_path, params: { movie: movie_params }, headers: @headers, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Title can't be blank")
      expect(body["errors"]).to include("Rating must be less than or equal to 5")
    end
  end

  describe "PUT /update" do
    it "updates an existing movie" do
      movie = create(:movie, user: @user)

      update_params = {
        title: "The Matrix",
        genre: "Action",
        rating: 4,
        status: "watched",
        notes: "Classic movie!",
      }

      put api_v1_movie_path(movie), params: { movie: update_params }, headers: @headers, as: :json

      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("The Matrix")
      expect(body["genre"]).to eq("Action")
      expect(body["rating"]).to eq(4)
      expect(body["status"]).to eq("watched")
    end
  end

  describe "DELETE /destroy" do
    it "deletes the specified movie" do
      movie = create(:movie, user: @user)

      delete api_v1_movie_path(movie), headers: @headers, as: :json

      expect(response).to have_http_status(:no_content)
      expect { Movie.find(movie.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns 404 when trying to delete a movie that does not belong to the user" do
      other_user = create(:user)
      movie = create(:movie, user: other_user)

      delete api_v1_movie_path(movie), headers: @headers, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "authentication" do
    it_behaves_like "unauthorized request", :get, -> { api_v1_movies_path }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_movies_path }, :invalid_token

    it_behaves_like "unauthorized request", :get, -> { api_v1_movie_path(SecureRandom.uuid) }, :no_token
    it_behaves_like "unauthorized request", :get, -> { api_v1_movie_path(SecureRandom.uuid) }, :invalid_token
    it_behaves_like "unauthorized request", :post, -> { api_v1_movies_path }, :no_token
    it_behaves_like "unauthorized request", :post, -> { api_v1_movies_path }, :invalid_token

    it_behaves_like "unauthorized request", :put, -> { api_v1_movie_path(SecureRandom.uuid) }, :no_token
    it_behaves_like "unauthorized request", :put, -> { api_v1_movie_path(SecureRandom.uuid) }, :invalid_token
    it_behaves_like "unauthorized request", :delete, -> { api_v1_movie_path(SecureRandom.uuid) }, :no_token
    it_behaves_like "unauthorized request", :delete, -> { api_v1_movie_path(SecureRandom.uuid) }, :invalid_token
  end
end
