class Test < ApplicationRecord
  belongs_to :suite
  has_many :steps, dependent: :destroy
  has_many :assertions, dependent: :destroy

  has_many :prep_tests, dependent: :destroy
  has_many :lead_steps, :through => :prep_tests, :source => :step
  has_many :lead_suites, :through => :prep_tests, :source => :suite

  validates :title, :name, presence: true
  validates :session_id, uniqueness: true, if: 'session_id.present?'

  serialize :cachesteps, Hash
  serialize :params, Hash

  def url
    "/test/#{name}/#{id}"
  end
end
