
FactoryBot.define do
  factory :muldo do
    sequence(:name) { |n| "Dd#{n}" }
    association :owner
    color 'Dore'
    reproduction 4
    sex 'M'
    pregnant false
    type 'Muldo'
  end
end
