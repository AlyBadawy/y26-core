FactoryBot.define do
  factory :mood_entry do
    association :user
    date { Time.zone.today }
    status { Random.rand(1..5) }
  end
end
