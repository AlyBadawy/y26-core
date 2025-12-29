class Session < ApplicationRecord
  belongs_to :user

  validates :ip_address, presence: true
  validates :user_agent, presence: true
  validates :refresh_token, presence: true, uniqueness: true

  def revoke!
    update!(revoked: true)
  end

  def is_valid_session?
    !(revoked? || expired?)
  end

  def is_valid_session_request?(request)
    is_valid_session? && ip_address == request.ip && user_agent == request.user_agent
  end

  def refresh!
    raise "Session token is revoked" if revoked?
    raise "Session token is expired" if expired?

    new_refresh_token = TokenGenerator.generate_refresh_token

    refresh_token_duration = AuthConfiguration.refresh_token_duration

    update!(refresh_token: new_refresh_token,
            refresh_count: self.refresh_count + 1,
            last_refreshed_at: Time.current,
            refresh_token_expires_at: refresh_token_duration.from_now)
  end

  def revoked?; revoked; end
  def expired?; refresh_token_expires_at < Time.current; end
end
