class AddColumnsToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :city_id, :integer
    add_column :articles, :state_id, :integer
    add_column :articles, :country_id, :integer
    add_column :articles, :zip_code_id, :integer
  end
end
