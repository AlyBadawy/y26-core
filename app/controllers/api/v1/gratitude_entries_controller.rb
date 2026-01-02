class Api::V1::GratitudeEntriesController < ApplicationController
  before_action :set_gratitude_entry, only: [:show, :update, :destroy]

  def index
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date range"], instructions: "Provide 'start_date' and 'end_date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @gratitude_entries = Current.user.gratitude_entries.where(date: start_date..end_date).order(date: :asc)
    render :index, status: :ok
  end

  def show
  end

  def create
    @gratitude_entry = Current.user.gratitude_entries.new(gratitude_entry_params)
    if @gratitude_entry.save
      render :show, status: :created
    else
      render json: { errors: @gratitude_entry.errors.full_messages, instructions: "Ensure 'date' and 'content' are provided." }, status: :unprocessable_content
    end
  end

  def update
    if @gratitude_entry.update(gratitude_entry_params)
      render :show, status: :ok
    else
      render json: { errors: @gratitude_entry.errors.full_messages, instructions: "Ensure 'date' and 'content' are provided." }, status: :unprocessable_content
    end
  end

  def destroy
    @gratitude_entry.destroy
    head :no_content
  end

  private

  def set_gratitude_entry
    @gratitude_entry = Current.user.gratitude_entries.find(params[:id])
  end

  def gratitude_entry_params
    params.expect(gratitude_entry: [:date, :content])
  end
end
