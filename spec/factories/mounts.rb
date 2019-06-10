FactoryBot.define do
  factory :mount do
    sequence(:name) { |n| "Mount#{n}" }
    association :owner
    color 'black'
    reproduction 0
    sex true
    pregnant false
  end
end
