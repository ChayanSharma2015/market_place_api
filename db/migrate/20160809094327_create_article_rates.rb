class CreateArticleRates < ActiveRecord::Migration
  def change
    create_table :article_rates do |t|
      t.integer :article_id
      t.integer :user_id
      t.integer :rate

      t.timestamps null: false
    end
  end
end
