class Assertion < ApplicationRecord
  belongs_to :test
  validates :condition, :test, presence: true

  after_initialize :set_defaults, unless: :persisted? # The set_defaults will only work if the object is new

  def set_defaults
    self.active  ||= true
  end

  def self.assertion_types
    {'text-in-page' => 'Text Contained in Page', 'page-title' => 'Page Title',
     'status-code' => 'Status Code', 'self-enter' => 'Enter Your Own Condition'}
  end
end
