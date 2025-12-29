FactoryBot.define do
  factory :session do
    association :user
    ip_address { "127.0.0.1" }
    user_agent { "Ruby/RSpec" }
    refresh_token { SecureRandom.hex(64) }
    refresh_count { 1 }
    last_refreshed_at { Time.current }
    refresh_token_expires_at { 1.week.from_now }
    revoked { false }
  end
end
