module EventableFrequency
  NONE = "none"
  ONCE = "once"
  DAILY = "daily"
  WEEKLY = "weekly"
  BI_WEEKLY = "bi_weekly"
  MONTHLY = "monthly"
  CUSTOM_DATES = "custom_dates"

  class << self
    def none; NONE end
    def once; ONCE end
    def daily; DAILY end
    def weekly; WEEKLY end
    def bi_weekly; BI_WEEKLY end
    def monthly; MONTHLY end
    def custom_dates; CUSTOM_DATES end

    def all
      [NONE, ONCE, DAILY, WEEKLY, BI_WEEKLY, MONTHLY, CUSTOM_DATES]
    end
  end
end
