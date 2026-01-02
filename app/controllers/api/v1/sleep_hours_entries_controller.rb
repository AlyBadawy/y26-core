class Api::V1::SleepHoursEntriesController < ApplicationController
  def index
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date range"], instructions: "Provide 'start_date' and 'end_date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @sleep_hours_entries = Current.user.sleep_hours_entries.where(date: start_date..end_date).order(date: :asc)
    render :index, status: :ok
  end

  def show
    begin
      date = Date.parse(params[:date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid date"], instructions: "Provide a valid 'date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @sleep_hours_entry = Current.user.sleep_hours_entries.find_by(date: date)
    if @sleep_hours_entry
      render :show, status: :ok
    else
      render json: { errors: ["Sleep hours entry not found"], instructions: "Create an entry using the upsert endpoint." }, status: :not_found
    end
  end

  def upsert
    payload = params.permit(:date, :hours)
    begin
      date = Date.parse(payload[:date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date"], instructions: "Provide 'date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    @sleep_hours_entry = Current.user.sleep_hours_entries.find_or_initialize_by(date: date)
    was_persisted = @sleep_hours_entry.persisted?

    unless payload[:hours].present? && (1..10).include?(payload[:hours].to_i)
      render json: { errors: ["Hours is invalid or missing"], instructions: "Hours must be an integer between 0 and 10." }, status: :unprocessable_content
      return
    end

    @sleep_hours_entry.hours = payload[:hours]
    if @sleep_hours_entry.save
      status_code = was_persisted ? :ok : :created
      render :show, status: status_code
    else
      render json: { errors: @sleep_hours_entry.errors.full_messages }, status: :unprocessable_content
    end
  end
end
