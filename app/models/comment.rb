class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
  belongs_to :parent_comment,foreign_key:"parent_comment_id",class_name:"Comment"
  has_many   :nested_comments, foreign_key:"parent_comment_id", class_name:"Comment", dependent: :destroy
  has_many   :likes, foreign_key:"comment_id", dependent: :destroy,class_name:"CommentLike"

  def children
    nested_comments.map do |child|
      new_child = child.attributes.merge(like_count:child.likes.count)
      [new_child] + child.children
    end
  end

  def self_and_children
    new_self = self.attributes.merge(like_count:self.likes.count)
    [new_self] + children
  end
end
