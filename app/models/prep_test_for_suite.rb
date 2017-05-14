class PrepTestForSuite < ApplicationRecord
  belongs_to :test
  belongs_to :suite
end
