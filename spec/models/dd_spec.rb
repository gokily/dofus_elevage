require 'rails_helper'

RSpec.describe Dd, type: :model do
  before do
    @user = build(:user)
    @dd = build(:dd, owner: @user, name: 'same')
  end

  it 'is invalid if the color is not in the defined ones' do
    @dd.color = 'super'
    @dd.valid?
    expect(@dd.errors[:color]).to include('Color must be within the possible choices.')
  end

  it 'is valid with a reproduction count of 0 to 5' do
    (0..5).each do |n|
      @dd.reproduction = n
      expect(@dd).to be_valid
    end
  end

  it 'is invalid with a reproduction count outside of 0 to 5' do
    @dd.reproduction = 6
    expect(@dd).to_not be_valid
    @dd.reproduction = -1
    expect(@dd).to_not be_valid
  end
end
