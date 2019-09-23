
class Muldo < Mount

  validates :reproduction, inclusion: 0..4
  validate :right_color

  def self.colors
    ['Amande', 'Amande et Emeraude', 'Amande et Ivoire',
     'Dore', 'Dore et Amande', 'Dore et Ebene', 'Dore et Emeraude',
     'Dore et Indigo', 'Dore et Ivoire', 'Dore et Orchidee', 'Dore et Pourpre',
     'Ebene', 'Ebene et Amande', 'Ebene et Emeraude', 'Ebene et Indigo',
     'Ebene et Ivoire', 'Ebene et Orchidee', 'Ebene et Pourpre', 'Emeraude',
     'Indigo', 'Indigo et Amande', 'Indigo et Emeraude', 'Indigo et Ivoire',
     'Indigo et Orchidee', 'Indigo et Pourpre', 'Ivoire', 'Ivoire et Emeraude',
     'Orchidee', 'Orchidee et Amande', 'Orchidee et Emeraude', 'Orchidee et Ivoire',
     'Orchidee et Pourpre', 'Pourpre', 'Pourpre et Amande', 'Pourpre et Emeraude',
     'Pourpre et Ivoire', 'Prune', 'Prune et Amande', 'Prune et Dore',
     'Prune et Dore', 'Prune et Ebene', 'Prune et Emeraude', 'Prune et Indigo',
     'Prune et Ivoire', 'Prune et Orchidee', 'Prune et Pourpre', 'Prune et Roux',
     'Prune et Turquoise', 'Roux', 'Roux et Amande', 'Roux et Dore',
     'Roux et Ebene', 'Roux et Emeraude', 'Roux et Indigo', 'Roux et Ivoire',
     'Roux et Orchidee', 'Roux et Pourpre', 'Turquoise', 'Turquoise et Amande',
     'Turquoise et Ebene', 'Turquoise et Emeraude', 'Turquoise et Indigo',
     'Turquoise et Ivoire', 'Turquoise et Orchidee', 'Turquoise et Pourpre',
     'Turquoise et Roux']
  end

  def get_icon
    'icon/' + color.downcase.sub(' et ', '_').sub('roux', 'rousse')
                   .sub('dore', 'doree')
  end

  def get_img
    'muldo/muldo_' + color.downcase.sub(' et ', '_')
  end

  def to_partial_path
    'mounts/mount'
  end

  def self.max_repro
    4
  end

  private

  def right_color
    unless Muldo.colors.include?(color)
      errors.add(:color, 'Color must be within the possible choices.')
    end
  end

end
