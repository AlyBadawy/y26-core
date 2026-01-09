FactoryBot.define do
  factory :book do
    association :user
    title { Faker::Book.title }
    author { Faker::Book.author }
    genre { Faker::Book.genre }
    rating { rand(1..5) }
    started_on { nil }
    finished_on { nil }
    status { "to_read" }
    notes { "My notes about the book" }
  end
end
