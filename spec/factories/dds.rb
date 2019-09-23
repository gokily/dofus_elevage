
FactoryBot.define do
  factory :dd do
    sequence(:name) { |n| "Dd#{n}" }
    association :owner
    color 'Doree'
    reproduction 4
    sex 'M'
    pregnant false
    type 'Dd'
  end
end
