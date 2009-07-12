require "migration_helpers" 
class CreateSavedEvents < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :saved_events, :force => true  do |t|
        t.integer :user_id, :event_id, :null => false, :default => false        
    end	
	
        create_index(:saved_events, :user_id)
	foreign_key :saved_events, :user_id, :users
	foreign_key :saved_events, :event_id, :events
  end

  def self.down
     drop_table :saved_events
  end
end
