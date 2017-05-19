class PrepTest < ApplicationRecord
  belongs_to :test
  belongs_to :step
  belongs_to :suite

  validates :test, presence: true
end
