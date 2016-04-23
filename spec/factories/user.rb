FactoryGirl.define do
  factory :user do
    username "testuser"
    email    { "#{username}@example.com" }
    password "password"
  end
end
