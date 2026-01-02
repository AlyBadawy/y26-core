FactoryBot.define do
  factory :sleep_hours_entry do
    association :user
    date { Time.zone.today }
    hours { Random.rand(1..10) }
  end
end
