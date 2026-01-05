class Api::V1::MoviesController < ApplicationController
  def index
    @movies = Current.user.movies
  end

  def show
    @movie = Current.user.movies.find(params[:id])
  end

  def create
    @movie = Current.user.movies.new(movie_params)
    if @movie.save
      render :show, status: :created
    else
      render json: { errors: @movie.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    @movie = Current.user.movies.find(params[:id])
    if @movie.update(movie_params)
      render :show
    else
      render json: { errors: @movie.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @movie = Current.user.movies.find(params[:id])
    @movie.destroy
    head :no_content
  end

  private

  def movie_params
    params.expect(movie: [:title, :genre, :rating, :started_on, :finished_on, :status, :notes])
  end
end
