class Result < ApplicationRecord
  belongs_to :test
  belongs_to :step
  belongs_to :assertion

  validates :test, :name, presence: true

  def url
    "/results/#{runID}"
  end
end
