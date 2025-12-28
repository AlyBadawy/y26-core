module ApplicationHelper
  extend self

  def format_date(date)
    date.strftime("%B %d, %Y")
  end

  def format_time(time)
    time.strftime("%I:%M %p")
  end

  def parse_time_param(val)
    return nil if val.blank?

    begin
      Time.zone.parse(val)
    rescue ArgumentError, TypeError
      nil
    end
  end

  def coerce_numeric(val)
    # If already a numeric type, return it unchanged
    return val if val.is_a?(Numeric)

    # Blank or nil values are considered invalid
    raise ArgumentError, "Value must be numeric" if val.nil? || val.to_s.strip.empty?

    str = val.to_s
    begin
      Float(str)
    rescue ArgumentError, TypeError
      raise ArgumentError, "Value must be numeric"
    end
  end

  def coerce_numeric_or_nil(val)
    # If already a numeric type, return it unchanged
    return val if val.is_a?(Numeric)

    # Blank or nil values return nil
    return nil if val.nil? || val.to_s.strip.empty?

    str = val.to_s
    begin
      Float(str)
    rescue ArgumentError, TypeError
      raise ArgumentError, "Value must be numeric"
    end
  end
end
