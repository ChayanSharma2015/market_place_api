class CreateLikedDislikedUsers < ActiveRecord::Migration
  def change
    create_table :liked_disliked_users do |t|
      t.integer :user_id
      t.integer :liked_disliked_user_id
      t.string :status

      t.timestamps null: false
    end
  end
end
