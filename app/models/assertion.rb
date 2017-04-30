class Assertion < ApplicationRecord
  belongs_to :test
  validates :condition, presence: true

  after_initialize :set_defaults, unless: :persisted? # The set_defaults will only work if the object is new

  def set_defaults
    self.active  ||= true
  end
end
