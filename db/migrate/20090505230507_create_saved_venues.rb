require "migration_helpers" 
class CreateSavedVenues < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :saved_venues, :force => true  do |t|
        t.integer :user_id, :venue_id, :null => false, :default => false        
    end	
	
        create_index(:saved_venues, :user_id)
	foreign_key :saved_venues, :user_id, :users
	foreign_key :saved_venues, :venue_id, :venues
  end

  def self.down
     drop_table :saved_venues
  end
end
