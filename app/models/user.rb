class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :mounts, dependent: :destroy
  has_many :muldos, dependent: :destroy
  has_many :dds, dependent: :destroy

  validates :username, presence: true
  validates :server, presence: true
end
