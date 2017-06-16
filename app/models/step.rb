class Step < ApplicationRecord
  belongs_to :test
  serialize :config
  has_many :extracts, dependent: :destroy
  has_many :results

  validates :wait, numericality: true
  validates :action_type, presence: true

  has_many :prep_tests, dependent: :destroy
  has_many :pre_tests, class_name: 'Test', through: :prep_tests, :source => :test

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

  def title
    action = "#{web_step_types[action_type]} "
    noun = ''

    case action_type
      when 'pageload'
        noun = webpage
      when 'scroll'
        noun = "to #{scrollLeft}, #{scrollTop}"
      when 'keypress'
        noun = typed
      when 'click'
        noun = "on #{translateClickSelector JSON.parse(step.selector,:symbolize_names => true)}"
      else
        true
    end

    action + noun
  end

  def screenShot(runId)
    "https://s3.amazonaws.com/#{ENV['bucket']}/#{runId}-#{order}"
  end
end
