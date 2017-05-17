class Suite < ApplicationRecord
  belongs_to :user
  has_many :tests, dependent: :destroy

  has_many :prep_test_for_suites, dependent: :destroy
  has_many :prep_tests, class_name: 'Test', through: :prep_test_for_suites, :source => :test

  validates :title, :name, presence: true
end
