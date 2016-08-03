class CreateLikeDislikes < ActiveRecord::Migration
  def change
    create_table :like_dislikes do |t|
      t.integer :liker_disliker_id
      t.integer :liked_disliked_id
      t.boolean :liked_status

      t.timestamps null: false
    end
  end
end
