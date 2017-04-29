class Step < ApplicationRecord
  belongs_to :test
  serialize :config

  validates :wait, numericality: true
  validates :action_type, presence: true

  def self.web_step_types
    {'pageload' => 'load page', 'scroll' => 'scroll', 'keypress' => 'type',
         'click' => 'click', 'resize' => 'resize'}
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
