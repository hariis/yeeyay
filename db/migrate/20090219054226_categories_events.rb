require "migration_helpers" 
class CategoriesEvents < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :categories_events, :id => false , :force => true  do |t|
		t.column :category_id, :integer, :null => false
		t.column :event_id , :integer, :null => false
    end	
        foreign_key(:categories_events, :event_id, :events)	
        foreign_key(:categories_events, :category_id, :categories)
  end

  def self.down
    drop_table :categories_events
  end
end
