class PrepTest < ApplicationRecord
  belongs_to :test
  belongs_to :step

  validates :test, :step, presence: true
end
