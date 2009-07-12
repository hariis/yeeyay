require "migration_helpers"
class CreateEventReviews < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :event_reviews, :force => true  do |t|
      t.string :title, :null => false
      t.text   :details, :null => false
      t.boolean :review_type, :default => 0
      t.integer :added_by, :null => false
      t.references :event, :null => false
      t.timestamps
    end
    create_index(:event_reviews, :added_by, :event_id)
    foreign_key(:event_reviews, :added_by, :users)	
    foreign_key(:event_reviews, :event_id,  :events)
  end

  def self.down
    drop_table :event_reviews
  end
end
