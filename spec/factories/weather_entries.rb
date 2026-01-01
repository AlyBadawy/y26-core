FactoryBot.define do
  factory :weather_entry do
    association :user
    date { Time.zone.today }
    status { "sun" }
  end
end
