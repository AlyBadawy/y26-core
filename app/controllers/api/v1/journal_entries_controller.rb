class Api::V1::JournalEntriesController < ApplicationController
  before_action :set_journal_entry, only: [:show, :update, :destroy]

  def index
    begin
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
    rescue ArgumentError, TypeError
      render json: { errors: ["Invalid or missing date range"], instructions: "Provide 'start_date' and 'end_date' in YYYY-MM-DD format." }, status: :bad_request
      return
    end

    journaling_range = start_date..end_date
    @journal_entries = Current.user.journal_entries.where(journaled_at: journaling_range).order(journaled_at: :asc)
    render :index, status: :ok
  end

  def show
  end

  def create
    @journal_entry = Current.user.journal_entries.new(journal_entry_params)
    if @journal_entry.save
      render :show, status: :created
    else
      render json: { errors: @journal_entry.errors.full_messages, instructions: "Ensure 'date' and 'content' are provided." }, status: :unprocessable_content
    end
  end

  def update
    if @journal_entry.update(journal_entry_params)
      render :show, status: :ok
    else
      render json: { errors: @journal_entry.errors.full_messages, instructions: "Ensure 'date' and 'content' are provided." }, status: :unprocessable_content
    end
  end

  def destroy
    @journal_entry.destroy
    head :no_content
  end

  private

  def set_journal_entry
    @journal_entry = Current.user.journal_entries.find(params[:id])
  end

  def journal_entry_params
    params.expect(journal_entry: [:title, :content, :journaled_at])
  end
end
