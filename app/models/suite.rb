class Suite < ApplicationRecord
  belongs_to :user
  has_many :tests, dependent: :destroy

  has_many :prep_tests, dependent: :destroy
  has_many :pre_tests, class_name: 'Test', through: :prep_tests, :source => :test

  validates :title, :name, presence: true
end
