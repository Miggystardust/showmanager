# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :app do
    legal_name "MyString"
    mailing_address "MyString"
    phone_primary "MyString"
    phone_alt "MyString"
    phone_primary_has_sms false
  end
end
