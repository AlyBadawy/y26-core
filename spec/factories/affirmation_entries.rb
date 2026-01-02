FactoryBot.define do
  factory :affirmation_entry do
    association :user
    date { Time.zone.today }
    content { "I am confident and capable." }
  end
end
