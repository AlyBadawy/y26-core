FactoryBot.define do
  factory :movie do
    association :user
    title { Faker::Movie.title }
    genre { "Sci-Fi" }
    rating { 1 }
    watched_on { nil }
    status { "to_watch" }
    notes { "My notes about the movie" }
  end
end
