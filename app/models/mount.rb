class Mount < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :owner, presence: true
  validates :color, presence: true
  validates :reproduction, presence: true, inclusion: 0..4

  belongs_to :owner, class_name: 'User', foreign_key: :user_id

end
