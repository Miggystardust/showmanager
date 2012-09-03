# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'Test User'
    username 'testuser'
    email 'example@example.com'
    password 'please'
    password_confirmation 'please'
    admin false
  end

  factory :admin, class: User do
    name 'Test Admin'
    username 'admin'
    email 'admin@example.com'
    password 'please'
    password_confirmation 'please'
    admin true
  end
end
