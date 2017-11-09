class GenerationEvent < ApplicationRecord
  belongs_to :test
  belongs_to :template
end
