module SessionCreator
  extend self

  def create_session!(user, request)
    valid_user = user && user.is_a?(User) && user.persisted?
    valid_request = request.is_a?(ActionDispatch::Request)

    return nil unless valid_user && valid_request

    user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      refresh_token: TokenGenerator.generate_refresh_token,
      last_refreshed_at: Time.current,
      refresh_token_expires_at: 1.week.from_now,
    ).tap do |session|
      Current.session = session
      # Keep only the 10 most recent sessions for the user.
      # Evict older sessions (by updated_at) to limit total sessions.
      user.sessions.order(updated_at: :desc).offset(5).find_each do |old_session|
        old_session.destroy unless old_session.is_valid_session?
      end
    end
  end
end
