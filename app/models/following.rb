class Following < ApplicationRecord
  belongs_to :user
  belongs_to :following_friend, :class_name => "User
end
