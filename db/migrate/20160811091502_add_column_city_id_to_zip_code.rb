class AddColumnCityIdToZipCode < ActiveRecord::Migration
  def change
    add_column :zip_codes, :city_id, :integer
  end
end
