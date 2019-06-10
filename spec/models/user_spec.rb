# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do

  it 'is valid with a username, email, server and password' do
    user = build(:user)
    expect(user).to be_valid
  end

  it 'is invalid without an username' do
    user = build(:user, username: nil)
    user.valid?
    expect(user.errors[:username]).to include("can't be blank")
  end

  it 'is invalid with a blank username' do
    user = build(:user, username: '   ')
    user.valid?
    expect(user.errors[:username]).to include("can't be blank")
  end

  it 'is invalid without a server' do
    user = build(:user, server: nil)
    user.valid?
    expect(user.errors[:server]).to include("can't be blank")
  end

  it 'is invalid without an email address' do
    user = build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid without a correctly formated email address' do
    user = build(:user, email: 'toto')
    user.valid?
    expect(user.errors[:email]).to include('is invalid')
  end

  it 'is invalid with a duplicate email address' do
    create(:user, email: 'test@test.com')
    user = build(:user, email: 'test@test.com')
    user.valid?
    expect(user.errors[:email]).to include('has already been taken')
  end
end
