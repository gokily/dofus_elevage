
class Dd < Mount

  validates :reproduction, inclusion: 0..5
  validate :right_color
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

  def get_icon
    'icon/' + color.downcase.sub(' et ', '_') + '.png'
  end

  def get_img
    'dragodinde/dd_' + color.downcase.sub(' et ', '_') + '.webp'
  end

  def to_partial_path
    'mounts/mount'
  end

  def self.max_repro
    5
  end

  private

  def right_color
    unless Dd.colors.include?(color)
      errors.add(:color, 'Color must be within the possible choices.')
    end
  end
end