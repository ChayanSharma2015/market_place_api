class RemoveColumnsFromArticle < ActiveRecord::Migration
  def change
    remove_column :articles, :country_id, :integer
    remove_column :articles, :state_id, :integer
    remove_column :articles, :city_id, :integer
  end
end
