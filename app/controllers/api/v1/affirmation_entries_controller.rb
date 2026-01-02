class Api::V1::AffirmationEntriesController < ApplicationController
  before_action :set_affirmation_entry, only: [:show, :update, :destroy]

  def index
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date range"], instructions: "Provide 'start_date' and 'end_date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @affirmation_entries = Current.user.affirmation_entries.where(date: start_date..end_date).order(date: :asc)
    render :index, status: :ok
  end

  def show
  end

  def create
    @affirmation_entry = Current.user.affirmation_entries.new(affirmation_entry_params)
    if @affirmation_entry.save
      render :show, status: :created
    else
      render json: { errors: @affirmation_entry.errors.full_messages, instructions: "Ensure 'date' and 'content' are provided." }, status: :unprocessable_content
    end
  end

  def update
    if @affirmation_entry.update(affirmation_entry_params)
      render :show, status: :ok
    else
      render json: { errors: @affirmation_entry.errors.full_messages, instructions: "Ensure 'date' and 'content' are provided." }, status: :unprocessable_content
    end
  end

  def destroy
    @affirmation_entry.destroy
    head :no_content
  end

  private

  def set_affirmation_entry
    @affirmation_entry = Current.user.affirmation_entries.find(params[:id])
  end

  def affirmation_entry_params
    params.expect(affirmation_entry: [:date, :content])
  end
end
