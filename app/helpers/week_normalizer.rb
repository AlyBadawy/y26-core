module WeekNormalizer
  extend self

  def start_of_week(date = Date.current)
    date.beginning_of_week(:monday)
  end
end
