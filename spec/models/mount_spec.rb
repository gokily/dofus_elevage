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

  it 'is invalid without a pregnant status' do
    @mount.pregnant = nil
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

  describe 'look if a mount can breed' do
    context 'for a fertile mount with at least 1 reproduction left' do
      it 'returns true' do
        @mount.pregnant = false
        @mount.reproduction = 1
        expect(@mount.breedable?).to be true
      end
    end
    context 'for a already pregnant mount' do
      it 'returns false' do
        @mount.pregnant = true
        expect(@mount.breedable?).to be false
      end
    end
    context 'for a fertile mount with 0 reproduction left' do
      it 'returns false' do
        @mount.pregnant = false
        @mount.reproduction = 0
        expect(@mount.breedable?).to be false
      end

    end
  end

  describe 'mate two mounts together' do
    before do
      @mount.update_attributes({ reproduction: 4, pregnant: false, sex: 'M' })
      @second = build(:mount, owner: @user, reproduction: 4, pregnant: false, sex: 'F')
    end
    context 'with two breedable mounts of the opposite sex' do
      it 'mates them' do
        expect(@mount.mate(@second)).to eql 1
      end
    end
    context 'with two breedable mounts of the same sex' do
      it 'returns an error' do
        @second.sex = 'M'
        expect(@mount.mate(@second)).to eql 0
      end
    end
    context 'with at least one mount that is not breedable' do
      it 'returns an error' do
        @mount.reproduction = 0
        expect(@mount.mate(@second)).to eql 0
        expect(@second.mate(@mount)).to eql 0
      end
    end
  end
end
