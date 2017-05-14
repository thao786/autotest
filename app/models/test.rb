class Test < ApplicationRecord
  belongs_to :suite
  has_many :steps, dependent: :destroy
  has_many :assertions, dependent: :destroy

  has_many :prep_tests, dependent: :destroy
  has_many :lead_steps, :through => :prep_tests, :source => :step

  has_many :prep_test_for_suites, dependent: :destroy
  has_many :lead_suites, :through => :prep_test_for_suites, :source => :suite

  validates :title, :name, presence: true
  validates :session_id, uniqueness: true, if: 'session_id.present?'

  serialize :cachesteps, Hash
  serialize :params, Hash
end
