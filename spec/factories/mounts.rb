FactoryBot.define do
  factory :mount do
    sequence(:name) { |n| "Mount#{n}" }
    association :owner
    color 'Doree'
    reproduction 4
    sex 'M'
    pregnant false
  end
end
