module TokenGenerator
  extend self

  def generate_refresh_token
    secret = AuthConfiguration.session_secret
    algo = "SHA512"

    random_data = SecureRandom.hex(32)
    digest = OpenSSL::Digest.new(algo)
    hmac = OpenSSL::HMAC.hexdigest(digest, secret, random_data)

    "#{hmac}#{random_data}"
  end

  def generate_password_reset_token
    token = SecureRandom.alphanumeric(12)
    "#{token[0, 6]}-#{token[6, 6]}"
  end

  def friendly_token(length = 20)
    SecureRandom.urlsafe_base64(length).tr("lIO0", "sxyz")[0, length]
  end
end
