module AuthConfiguration
  extend self

  def refresh_token_duration
    1.week
  end

  def session_secret
    ENV["SESSION_SECRET"] || "default_session_secret"
  end

  def session_algorithm
    :hs512
  end

  def session_expiration_duration
    1.minute
  end

  def password_min_length
    8
  end

  def password_max_length
    128
  end

  def password_complexity
    RegexHelper::PASSWORD_REGEX
  end

  def password_expires_in
    90.days
  end

  def password_expires
    true
  end
end
