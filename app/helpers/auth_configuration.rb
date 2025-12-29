module AuthConfiguration
  extend self

  def refresh_token_duration
    1.week
  end

  def session_secret
    ENV["SESSION_SECRET"] || "default_session_secret"
  end
end
