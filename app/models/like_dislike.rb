class LikeDislike < ActiveRecord::Base
  belongs_to :liker_disliker, class_name: "User"
  belongs_to :liked_disliked, class_name: "User"
end
