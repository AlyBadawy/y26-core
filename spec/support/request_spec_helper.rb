module RequestSpecHelper
  def create_auth_trio(user: nil)
    user ||= create(:user)
    session = FactoryBot.create(:session, user: user)
    token = AuthEncoder.encode(session)
    [user, session, token]
  end

  def auth_headers(token: nil, user: nil, extra_headers: {})
    auth_token = "Bearer #{token ? token : create_auth_trio(user: user).third}"
      {
        'Accept' => 'application/json',
        'Authorization' => auth_token,
        'Content-Type' => 'application/json',
        "User-Agent" => "Ruby/RSpec",
      }.merge(extra_headers)
  end

  # def admin_auth_headers(extra_headers: {})
  #   auth_headers(admin: true, extra_headers: extra_headers)
  # end
end
