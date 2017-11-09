class Template < ApplicationRecord
  belongs_to :user
  has_many :generation_events
end
