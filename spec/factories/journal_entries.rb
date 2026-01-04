FactoryBot.define do
  factory :journal_entry do
    association :user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    journaled_at { Faker::Time.backward(days: 14, period: :evening) }
  end
end
