class Result < ApplicationRecord
  belongs_to :test
  belongs_to :step
  belongs_to :assertion

  validates :test, :name, presence: true

  def self.universal_assertions
    ["http-200", "ajax-200", "report", "step-succeed", "match-url"]
  end

  def url
    "/results/#{runId}"
  end
end
