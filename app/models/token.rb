class Token < ApplicationRecord
  validates_uniqueness_of :username, :allow_blank => true
end
