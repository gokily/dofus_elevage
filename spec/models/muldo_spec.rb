require 'rails_helper'

RSpec.describe Muldo, type: :model do
  before do
    @user = build(:user)
    @muldo = build(:muldo, owner: @user, name: 'same')
  end

  it 'is invalid if the color is not in the defined ones' do
    @muldo.color = 'super'
    @muldo.valid?
    expect(@muldo.errors[:color]).to include('Color must be within the possible choices.')
  end

  it 'is valid with a reproduction count of 0 to 4' do
    (0..4).each do |n|
      @muldo.reproduction = n
      expect(@muldo).to be_valid
    end
  end

  it 'is invalid with a reproduction count outside of 0 to 4' do
    @muldo.reproduction = 5
    expect(@muldo).to_not be_valid
    @muldo.reproduction = -1
    expect(@muldo).to_not be_valid
  end
end

