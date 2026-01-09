class Api::V1::BooksController < ApplicationController
  def index
    @books = Current.user.books
  end

  def show
    @book = Current.user.books.find(params[:id])
  end

  def create
    @book = Current.user.books.new(book_params)
    if @book.save
      render :show, status: :created
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    @book = Current.user.books.find(params[:id])
    if @book.update(book_params)
      render :show
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @book = Current.user.books.find(params[:id])
    @book.destroy
    head :no_content
  end

  private

  def book_params
    params.expect(book: [:title, :author, :genre, :rating, :started_on, :finished_on, :status, :notes])
  end
end
