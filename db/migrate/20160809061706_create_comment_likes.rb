class CreateCommentLikes < ActiveRecord::Migration
  def change
    create_table :comment_likes do |t|
      t.integer :comment_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
