class Assertion < ApplicationRecord
  belongs_to :test
  has_many :results, dependent: :destroy

  after_initialize :set_defaults, unless: :persisted? # The set_defaults will only work if the object is new

  def set_defaults
    self.active ||= true
  end

  def self.assertion_types
    {
        'text-in-page' => 'Text Contained in Page',
         'text-not-in-page' => 'Text Not Contained in Page',
         'html-in-page' => 'HTML Contained in Page',
         'html-not-in-page' => 'HTML not Contained in Page',
         'page-title' => 'Page Title',
         'status-code' => 'Status Code',
         'self-enter' => 'Enter Your Own Condition'
    }
  end

  def self.default_assertions
    {
        'http-200' => 'All Http request return 200 status',
        'ajax-200' => 'All Ajax request return 200 status',
        'report' => 'report',
        'step-succeed' => 'step completes successfully',
        'match-url' => 'url must match'
    }
  end
end
