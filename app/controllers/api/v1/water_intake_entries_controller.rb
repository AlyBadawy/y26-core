class Api::V1::WaterIntakeEntriesController < ApplicationController
  def index
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date range"], instructions: "Provide 'start_date' and 'end_date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @water_intake_entries = Current.user.water_intake_entries.where(date: start_date..end_date).order(date: :asc)
    render :index, status: :ok
  end

  def show
    begin
      date = Date.parse(params[:date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid date"], instructions: "Provide a valid 'date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @water_intake_entry = Current.user.water_intake_entries.find_by(date: date)
    if @water_intake_entry
      render :show, status: :ok
    else
      render json: { errors: ["Water intake entry not found"], instructions: "Create an entry using the upsert endpoint." }, status: :not_found
    end
  end

  def upsert
    payload = params.permit(:date, :cups)
    begin
      date = Date.parse(payload[:date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date"], instructions: "Provide 'date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @water_intake_entry = Current.user.water_intake_entries.find_or_initialize_by(date: date)
    was_persisted = @water_intake_entry.persisted?

    unless payload[:cups].present? && (1..10).include?(payload[:cups].to_i)
      render json: { errors: ["Cups is invalid or missing"], instructions: "Cups must be an integer between 1 and 10." }, status: :unprocessable_content
      return
    end

    @water_intake_entry.cups = payload[:cups]
    if @water_intake_entry.save
      status_code = was_persisted ? :ok : :created
      render :show, status: status_code
    else
      render json: { errors: @water_intake_entry.errors.full_messages }, status: :unprocessable_content
    end
  end
end
