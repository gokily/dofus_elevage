# frozen_string_literal: true

class Mount < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  default_scope -> { order(created_at: :desc) }

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :owner, presence: true
  validates :color, presence: true
  validates :reproduction, presence: true, inclusion: 0..4

  def self.colors
    %w[Doree Indigo Ebene Pourpre Orchidee Roux Amande Prune Emeraude Ivoire Turquoise]
  end
end
