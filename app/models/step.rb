class Step < ApplicationRecord
  belongs_to :test
  serialize :config

  validates :wait, numericality: true
  validates :action_type, presence: true

  has_many :prep_tests, class_name: 'Test', through: :prep_tests, :source => :test

  def self.web_step_types
    {'pageload' => 'load page', 'scroll' => 'scroll', 'keypress' => 'type',
         'click' => 'click', 'resize' => 'resize'}
  end

  after_initialize :set_defaults, unless: :persisted? # The set_defaults will only work if the object is new

  def set_defaults
    self.active  ||= true
  end

  def complete?
    case action_type
      when 'pageload'
        webpage.present?
      when 'scroll'
        scrollLeft.present? and scrollTop.present?
      when 'keypress'
        typed.present?
      when 'click'
        selector.present?
      else
        true
    end
  end
end
