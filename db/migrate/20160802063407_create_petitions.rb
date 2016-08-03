class CreatePetitions < ActiveRecord::Migration
  def change
    create_table :petitions do |t|
      t.integer :article_id

      t.timestamps null: false
    end
  end
end
