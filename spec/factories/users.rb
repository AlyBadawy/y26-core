FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    email_verified { Time.current }
    new_email { Faker::Internet.email }
    username { Faker::Internet.username(specifier: 3..20) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    bio { Faker::Lorem.paragraph }
  end
end
