require "migration_helpers"
class CreateVenueReviews < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :venue_reviews, :force => true  do |t|
      t.string :title, :null => false
      t.text   :details, :null => false
      t.boolean :review_type, :default => 0
      t.integer :added_by, :null => false
      t.references :venue, :null => false
      t.timestamps
    end
    create_index(:venue_reviews, :added_by, :venue_id)
    foreign_key(:venue_reviews, :added_by, :users)	
    foreign_key(:venue_reviews, :venue_id,  :venues)
  end

  def self.down
    drop_table :venue_reviews
  end
end
