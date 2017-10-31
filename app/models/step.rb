class Step < ApplicationRecord
  belongs_to :test
  serialize :selector
  serialize :config
  has_many :extracts, dependent: :destroy

  validates :wait, numericality: true
  validates :action_type, presence: true

  has_many :prep_tests, dependent: :destroy
  has_many :pre_tests, class_name: 'Test', through: :prep_tests, :source => :test

  def self.web_step_types
      {'pageload' => 'load url in browser',
       # 'pageloadCurl' => 'load page with Curl',
       'scroll' => 'scroll',
       'keypress' => 'type',
       'click' => 'click',
       'resize' => 'Resize'}
  end

  after_initialize :set_defaults, unless: :persisted? # The set_defaults will only work if the object is new

  def set_defaults
    # self.active ||= true
  end

  def complete?
    case action_type
      when 'pageload'
        webpage.present?
      when 'pageloadCurl'
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
    action = "#{Step.web_step_types[action_type]} "
    noun = ''

    case action_type
      when 'pageload'
        noun = webpage
      when 'scroll'
        noun = "to #{scrollLeft}, #{scrollTop}"
      when 'keypress'
        noun = typed
      when 'click'
        noun = "on #{ApplicationController.helpers.translateClickSelector selector}"
      else
        true
    end

    action + noun
  end
end
