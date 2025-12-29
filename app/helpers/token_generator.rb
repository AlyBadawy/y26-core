module TokenGenerator
  extend self

  def generate_refresh_token
    secret = AuthConfiguration.session_secret
    algo = "SHA256"

    random_data = SecureRandom.hex(32)
    digest = OpenSSL::Digest.new(algo)
    hmac = OpenSSL::HMAC.hexdigest(digest, secret, random_data)

    "#{hmac}#{random_data}"
  end
end
