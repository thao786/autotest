class Test < ApplicationRecord
  belongs_to :suite
  has_many :steps

  validates :title, :name, presence: true
  validates :session_id, uniqueness: true, if: 'session_id.present?'

  serialize :cachesteps, Hash
  serialize :params, Hash
end
