FactoryBot.define do
  factory :water_intake_entry do
    association :user
    date { Time.zone.today }
    cups { Random.rand(1..10) }
  end
end
