class Like < ApplicationRecord
  belongs_to :user_id, :class_name => "User"
  belongs_to :post_id, :class_name => "Post"
end
