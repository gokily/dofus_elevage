# frozen_string_literal: true

class Mount < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  default_scope -> {order(created_at: :desc)}
  has_parents(options = {current_spouse: true})
  validates :name, presence: true, uniqueness: {scope: :user_id}
  validates :owner, presence: true
  validates :color, presence: true
  validates :reproduction, presence: true, inclusion: 0..4
  validates :pregnant, inclusion: [true, false]

  def self.colors
    %w[Doree Indigo Ebene Pourpre Orchidee Roux Amande Prune Emeraude Ivoire Turquoise]
  end

  def breedable?
    self.reproduction != 0 && self.pregnant == false
  end

  def sterile?
    self.reproduction == 0 && self.pregnant == false
  end

  def repro_status
    if self.breedable?
      return 'Fertile'
    elsif self.sterile?
      return 'Sterile'
    else
      return 'Pregnant'
    end
  end

  def mate(other)
    if (self.sex != other.sex) && self.breedable? && other.breedable?
      if (self.sex == 'F')
        self.pregnant = true
        self.current_spouse_id = other.id
      else
        other.pregnant = true
        other.current_spouse_id = self.id
      end
      self.reproduction -= 1
      other.reproduction -= 1
      if self.save! && other.save!
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

end
