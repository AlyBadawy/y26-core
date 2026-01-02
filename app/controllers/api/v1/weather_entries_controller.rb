class Api::V1::WeatherEntriesController < ApplicationController
  def index
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date range"], instructions: "Provide 'start_date' and 'end_date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @weather_entries = Current.user.weather_entries.where(date: start_date..end_date).order(date: :asc)
    render :index, status: :ok
  end

  def show
    begin
      date = Date.parse(params[:date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid date"], instructions: "Provide a valid 'date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @weather_entry = Current.user.weather_entries.find_by(date: date)
    if @weather_entry
      render :show, status: :ok
    else
      render json: { status: "" }, status: :ok
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

    @weather_entry = Current.user.weather_entries.find_or_initialize_by(date: date)
    was_persisted = @weather_entry.persisted?

    unless payload[:status].present? && WeatherEntry.statuses.key?(payload[:status].to_s)
      render json: { errors: ["Status is invalid or missing"], instructions: "Valid statuses: #{WeatherEntry.statuses.keys.join(', ')}" }, status: :unprocessable_content
      return
    end

    @weather_entry.status = payload[:status]

    if @weather_entry.save
      status_code = was_persisted ? :ok : :created
      render :show, status: status_code
    else
      render json: { errors: @weather_entry.errors.full_messages }, status: :unprocessable_content
    end
  end
end
