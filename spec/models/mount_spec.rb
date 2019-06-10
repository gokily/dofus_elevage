# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mount, type: :model do
  before do
    @user = build(:user)
    @mount = build(:mount, owner: @user, name: 'same')
  end

  it 'is valid with a name, owner, color, reproduction count,
sex and pregnant status' do
    second = build(:mount)
    expect(second).to be_valid
  end

  it 'is invalid without a name' do
    @mount.name = nil
    @mount.valid?
    expect(@mount.errors[:name]).to include("can't be blank")
  end

  it 'is invalid without an owner' do
    @mount.owner = nil
    @mount.valid?
    expect(@mount.errors[:owner]).to include("can't be blank")
  end

  it 'is invalid without a color' do
    @mount.color = '  '
    @mount.valid?
    expect(@mount.errors[:color]).to include("can't be blank")
  end

  it 'is invalid without a reproduction count' do
    @mount.reproduction = nil
    @mount.valid?
    expect(@mount.errors[:reproduction]).to include("can't be blank")
  end

  it 'is valid with a reproduction count of 0 to 4' do
    (0..4).each do |n|
      @mount.reproduction = n
      expect(@mount).to be_valid
    end
  end

  it 'is invalid with a reproduction count outside of 0 to 4' do
    @mount.reproduction = 5
    expect(@mount).to_not be_valid
    @mount.reproduction = -1
    expect(@mount).to_not be_valid
  end

  it 'does not allow duplicate mount names per user' do
    @user.save
    @mount.save
    mount_params = attributes_for(:mount, name: 'same')
    second = @user.mounts.build(mount_params)
    expect(second).to_not be_valid
  end

  it 'allows duplicate mount names for different users' do
    @user.save
    @mount.save
    mount_params = attributes_for(:mount, name: 'same')
    other_user = create(:user)
    other_mount = other_user.mounts.build(mount_params)
    expect(other_mount).to be_valid
  end
end
