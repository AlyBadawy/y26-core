class Api::V1::CalendarHelperController < ApplicationController
  skip_authentication! only: %i[week_starting]

  def week_starting
    render json: { year: 2026, month: 1, day: 1 }
  end
end
