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

  it 'is invalid if the color is not in the defined ones' do
    @mount.color = 'super'
    @mount.valid?
    expect(@mount.errors[:color]).to include('Color must be within the possible choices.')
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

  describe 'get the ancestors to the n-th degree' do
    before do
      @user = build(:user)
      @mount = build(:mount, owner: @user, name: 'peco')
    end

    context 'for a mount with no known parents' do
      it 'returns a hash with all values set to nil' do
        ret = @mount.ancestors(1)
        expect(ret.length).to eql 2
        expect(ret['F']).to be_nil
        expect(ret['M']).to be_nil
      end
    end

    context 'for a mount with known ancestors' do
      before do
        @father = build(:mount, owner: @user, name: 'father', sex: 'M')
        @mother = build(:mount, owner: @user, name: 'mother', sex: 'F')
        @mount.add_father(@father)
        @mount.add_mother(@mother)
      end

      context 'for a mount with a father and mother' do
        it 'returns a hash with the id of the father and mother' do
          ret = @mount.ancestors(1)
          expect(ret['F'].id).to eql @father.id
          expect(ret['M'].id).to eql @mother.id
        end
      end

      context 'for a mount with a FF, MF and MM' do
        it 'returns a hash with the parents and the known grand-parents' do
          mf = build(:mount, owner: @user, name: 'mf', sex: 'M')
          ff = build(:mount, owner: @user, name: 'ff', sex: 'M')
          mm = build(:mount, owner: @user, name: 'mm', sex: 'F')
          @mother.add_father(mf)
          @mother.add_mother(mm)
          @father.add_father(ff)
          ret = @mount.ancestors(2)
          expect(ret.length).to eql(6)
          expect(ret['MM'].id).to eql mm.id
          expect(ret['MF'].id).to eql mf.id
          expect(ret.has_key?('FM')).to be true
          expect(ret['FM']).to be_nil
          expect(ret['FF'].id).to eql ff.id
        end
      end
    end

  end
end
