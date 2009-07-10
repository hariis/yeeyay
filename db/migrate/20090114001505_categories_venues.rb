require "migration_helpers" 
class CategoriesVenues < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :categories_venues, :id => false , :force => true  do |t|
		t.column :category_id, :integer, :null => false
		t.column :venue_id , :integer, :null => false
    end	
        foreign_key(:categories_venues, :venue_id,:venues)	
        foreign_key(:categories_venues, :category_id,:categories)
  end

  def self.down
    drop_table :categories_venues
  end
end
