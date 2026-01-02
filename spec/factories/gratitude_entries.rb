FactoryBot.define do
  factory :gratitude_entry do
    association :user
    date { Time.zone.today }
    content { "I am grateful for my supportive family." }
  end
end
