# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:owner] do
    username 'Toto'
    server 'Ily'
    sequence(:email) { |n| "test#{n}@test.com" }
    password 'password'
    password_confirmation 'password'
    confirmed_at { Date.today }
  end
end
