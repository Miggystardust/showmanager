# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :act do
    stage_name 'Binky'
    length '1:23'
    short_description 'my_act'
  end
end
