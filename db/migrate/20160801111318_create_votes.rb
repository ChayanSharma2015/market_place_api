class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :voter_id
      t.integer :article_id
      t.string :vote_status

      t.timestamps null: false
    end
  end
end
