# frozen_string_literal: true

class Mount < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  default_scope -> { order(created_at: :desc) }
  has_parents(options = {current_spouse: true})
  validates :name, presence: true, uniqueness: {scope: :user_id}
  validates :owner, presence: true
  validates :color, presence: true
  validates :reproduction, presence: true, inclusion: 0..4
  validates :pregnant, inclusion: [true, false]
  validate :right_color
  validate :male_pregnant

  scope :mates, ->(mount, consang) {
    where('sex == ? AND pregnant == 0 AND reproduction != 0', \
          mount.sex == 'M' ? 'F' : 'M').select do |ind|
      consang == 'false' ? !ind.consang?(mount, 3) : true
    end
  }

  def self.colors
    ['Amande', 'Amande et Doree', 'Amande et Ebene', 'Amande et Emeraude',
     'Amande et Indigo', 'Amande et Indigo', 'Amande et Ivoire',
     'Amande et Orchidee', 'Amande et Pourpre', 'Amande et Rousse',
     'Amande et Turquoise', 'Doree', 'Doree et Ebene', 'Doree et Emeraude',
     'Doree et Indigo', 'Doree et Ivoire', 'Doree et Orchidee',
     'Doree et Pourpre', 'Doree et Rousse', 'Doree et Turquoise',
     'Ebene', 'Ebene et Emeraude', 'Ebene et Indigo', 'Ebene et Orchidee',
     'Ebene et Pourpre', 'Ebene et Rousse', 'Ebene et Turquoise',
     'Emeraude', 'Emeraude et Indigo', 'Emeraude et Ivoire',
     'Emeraude et Turquoise', 'Indigo', 'Indigo et Ivoire', 'Indigo et Orchidee',
     'Indigo et Pourpre', 'Indigo et Rousse', 'Indigo et Turquoise', 'Ivoire',
     'Ivoire et Orchidee', 'Ivoire et Pourpre', 'Ivoire et Rousse',
     'Ivoire et Turquoise', 'Orchidee', 'Orchidee et Pourpre', 'Orchidee et Rousse',
     'Pourpre', 'Pourpre et Rousse', 'Prune', 'Prune et Doree', 'Prune et Ebene',
     'Prune et Emeraude', 'Prune et Indigo', 'Prune et Ivoire', 'Prune et Orchidee',
     'Prune et Pourpre', 'Prune et Rousse', 'Prune et Turquoise', 'Rousse',
     'Turquoise', 'Turquoise et Orchidee', 'Turquoise et Pourpre', 'Turquoise et Rousse']
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

  def get_icon
    'icon/' + color.downcase.sub(' et ', '_')
  end

  def get_img
    'dragodinde/dd_' + color.downcase.sub(' et ', '_')
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

  def right_color
    unless Mount.colors.include?(color)
      errors.add(:color, 'Color must be within the possible choices.')
    end
  end

  def male_pregnant
    if pregnant == true && sex == 'M'
      errors.add(:pregnant, 'Male cannot be pregnant')
    end
  end
end
