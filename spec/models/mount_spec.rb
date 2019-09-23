# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mount, type: :model do
  before do
    @user = build(:user)
    @mount = build(:mount, owner: @user, name: 'same')
  end

  it 'is valid with a name, owner, color, reproduction count,
sex, pregnant status and type' do
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


  it 'is invalid without a pregnant status' do
    @mount.pregnant = nil
    expect(@mount).to_not be_valid
  end

  it 'is invalid without a sex status' do
    @mount.sex = nil
    expect(@mount).to_not be_valid
  end

  it 'is invalid for a male to be pregnant' do
    @mount.sex = 'M'
    @mount.pregnant = true
    expect(@mount).to_not be_valid
  end

  it 'is invalid without a type' do
    @mount.type = nil
    expect(@mount).to_not be_valid
  end

  it 'is invalid without a type in the defined ones' do
    @mount.type = 'coucou'
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

  describe 'breedable? looks if a mount can breed' do
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

  describe 'mate mates two mounts together' do
    before do
      @mount.update_attributes({reproduction: 4, pregnant: false, sex: 'M'})
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
    context 'with two breedable mounts of different type' do
      it 'returns an error' do
        @second.type = 'Muldo'
        expect(@mount.mate(@second)).to eql 0
      end
    end
  end

  describe 'ancestors(n) gets the ancestors to the n-th degree' do
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
        @father = create(:mount, owner: @user, name: 'father', sex: 'M')
        @mother = create(:mount, owner: @user, name: 'mother', sex: 'F')
        @mount.father_id = @father.id
        @mount.mother_id = @mother.id
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
          mf = create(:mount, owner: @user, name: 'mf', sex: 'M')
          ff = create(:mount, owner: @user, name: 'ff', sex: 'M')
          mm = create(:mount, owner: @user, name: 'mm', sex: 'F')
          @mother.father_id = mf.id
          @mother.mother_id = mm.id
          @father.father_id = ff.id
          @mother.save
          @father.save
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

  describe 'consang?(mount, n) looks if the mounts are consanguineous at the \
            n-th degree' do
    before do
      @father = create(:mount, owner: @user, name: 'father', sex: 'M')
      @mother = create(:mount, owner: @user, name: 'mother', sex: 'F')
      @other = build(:mount, owner: @user, name: 'other')
      @mount.father_id = @father.id
      @mount.mother_id = @mother.id
    end

    context 'for two unrelated mounts' do
      it 'returns false' do
        expect(@mount.consang?(@other, 3)).to be false
      end
    end

    context 'for two related mounts' do
      before do
        @other.father_id = @father.id
      end
      it 'returns true' do
        expect(@mount.consang?(@other, 3)).to be true
        expect(@mount.consang?(@other, 1)).to be true
      end
    end

    context 'for two related mounts at the grand parent level' do
      before do
        @ofather = create(:mount, owner: @user, name: 'ofather', sex: 'M')
        @ff = create(:mount, owner: @user, name: 'ff', sex: 'M')
        @other.father_id = @ofather.id
        @ofather.father_id = @ff.id
        @father.father_id = @ff.id
        @ofather.save
        @father.save
      end
      it 'returns false for n = 1' do
        expect(@mount.consang?(@other, 1)).to be false
      end
      it 'returns true for n = 2' do
        expect(@mount.consang?(@other, 2)).to be true
      end
    end
  end
end
