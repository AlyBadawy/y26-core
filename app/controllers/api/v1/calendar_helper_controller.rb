class Api::V1::CalendarHelperController < ApplicationController
  def week_starting
    render json: { year: 2026, month: 1, day: 1 }
  end
end
