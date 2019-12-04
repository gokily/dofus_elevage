# frozen_string_literal: true

class Mount < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  default_scope -> { order(created_at: :desc) }
  has_parents(options = { current_spouse: true })
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :owner, presence: true
  validates :color, presence: true
  validates :reproduction, presence: true
  validates :pregnant, inclusion: [true, false]
  #validates :type, presence: true, inclusion: %w[Dd Muldo]
  validate :male_pregnant

  scope :mates, ->(mount, consang) {
    where('sex = ? AND pregnant = false AND reproduction != 0 AND type = ?', \
          mount.sex == 'M' ? 'F' : 'M', mount.class.to_s).select do |ind|
      consang == 'false' ? !ind.consang?(mount, 3) : true
    end
  }

  scope :pregnant, -> { where('pregnant = true') }
  scope :fertile, -> { where('pregnant = false AND reproduction != 0') }


  def breedable?
    reproduction != 0 && pregnant == false
  end

  def sterile?
    reproduction == 0 && pregnant == false
  end

  def repro_status
    if breedable?
      return 'Fertile'
    elsif sterile?
      return 'Sterile'
    else
      return 'Pregnant'
    end
  end

  def mate(other)
    if sex != other.sex && breedable? && other.breedable? && type == other.type
      if (sex == 'F')
        self.pregnant = true
        self.current_spouse_id = other.id
      else
        other.pregnant = true
        other.current_spouse_id = id
      end
      self.reproduction -= 1
      other.reproduction -= 1
      if save! && other.save!
        return 1
      else
        return 0
      end
    else
      return 0
    end
  end

  def translate_sex
    sex == 'M' ? 'Male' : 'Female'
  end

  def ancestors(n)
    i = 0
    ret = {}
    prev_gen = []
    while i < n
      if i.zero?
        new_gen = {}
        new_gen['F'] = Mount.find_by(id: father_id)
        new_gen['M'] = Mount.find_by(id: mother_id)
      else
        new_gen = {}
        prev_gen.each do |key|
          ind = Mount.find_by(id: ret[key])
          new_gen[key + 'F'] = ind ? Mount.find_by(id: ind.father_id) : nil
          new_gen[key + 'M'] = ind ? Mount.find_by(id: ind.mother_id) : nil
        end
      end
      prev_gen = new_gen.keys
      ret = ret.merge(new_gen)
      i += 1
    end
    ret
  end

  def consang?(mount, n)
    ances1 = ancestors(n)
    ances2 = mount.ancestors(n)
    ances1.each do |_key, ind|
      next if ind.nil?
      ances2.each do |_key2, ind2|
        return true if !ind2.nil? && ind.id == ind2.id
      end
    end
    false
  end

  private

  def male_pregnant
    if pregnant == true && sex == 'M'
      errors.add(:pregnant, 'Male cannot be pregnant')
    end
  end
end
