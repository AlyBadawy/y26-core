class Api::V1::MoodEntriesController < ApplicationController
  def index
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date range"], instructions: "Provide 'start_date' and 'end_date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @mood_entries = Current.user.mood_entries.where(date: start_date..end_date).order(date: :asc)
    render :index, status: :ok
  end

  def show
    begin
      date = Date.parse(params[:date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid date"], instructions: "Provide a valid 'date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @mood_entry = Current.user.mood_entries.find_by(date: date)
    if @mood_entry
      render :show, status: :ok
    else
      render json: { status: 0 }, status: :ok
    end
  end

  def upsert
    payload = params.permit(:date, :status)
    begin
      date = Date.parse(payload[:date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date"], instructions: "Provide 'date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @mood_entry = Current.user.mood_entries.find_or_initialize_by(date: date)
    was_persisted = @mood_entry.persisted?

    unless payload[:status].present? && (1..5).include?(payload[:status].to_i)
      render json: { errors: ["Status is invalid or missing"], instructions: "Status must be an integer between 1 and 5." }, status: :unprocessable_content
      return
    end

    @mood_entry.status = payload[:status]
    if @mood_entry.save
      status_code = was_persisted ? :ok : :created
      render :show, status: status_code
    else
      render json: { errors: @mood_entry.errors.full_messages }, status: :unprocessable_content
    end
  end
end
