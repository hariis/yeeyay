require "migration_helpers"
class CreateVenues < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :venues, :force => true  do |t|
      t.string :name, :null => false
      t.text   :description
      t.text   :highlights
      t.string :url, :phone, :email
      t.string :street_address, :null => false
      t.string :city_state_zip, :null => false
      t.decimal :latitude, :longitude, :null => false,  :precision => 15, :scale => 10      
      t.integer :added_by, :null => false
      t.timestamps
    end
    create_index(:venues, :name, :latitude, :longitude)
    foreign_key(:venues, :added_by, :users)
    
    
  end

  def self.down
    drop_table :venues
  end
end
