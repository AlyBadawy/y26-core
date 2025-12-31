require "jwt"

module AuthEncoder
  extend self

  def encode(session)
    return nil unless session && session.class == Session

    base_payload = {
      jti: session.id,
      exp: expiry_duration.from_now.to_i,
      sub: "session-access-token",
      refresh_count: session.refresh_count,
    }

    session_payload = {
      ip: session.ip_address,
      agent: session.user_agent,
    }

    payload = base_payload.merge(session_payload)
    begin
      ::JWT.encode(payload, secret, algorithm, { kid: "hmac" })
    rescue ::JWT::EncodeError
      raise "Token encoding failed"
    end
  end

  def decode(token)
    begin
      decoded = ::JWT.decode(token, secret, true, { algorithm: algorithm, verify_jti: true, iss: "securial" })
    rescue ::JWT::DecodeError
      raise "Token decoding failed"
    end
    decoded.first
  end

  private

  def secret
    AuthConfiguration.session_secret
  end

  def algorithm
    AuthConfiguration.session_algorithm.to_s.upcase
  end

  def expiry_duration
    AuthConfiguration.session_expiration_duration
  end
end
