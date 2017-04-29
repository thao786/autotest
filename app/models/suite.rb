class Suite < ApplicationRecord
  belongs_to :user
  has_many :tests, dependent: :destroy

  validates :title, :name, presence: true
end
