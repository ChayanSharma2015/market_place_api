class CreateZipCodes < ActiveRecord::Migration
  def change
    create_table :zip_codes do |t|
      t.integer :number

      t.timestamps null: false
    end
  end
end
