require "migration_helpers"
class AddEvents < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
     create_table :events ,:force => true do |t|
          t.string :title, :null => false
          t.datetime :start_dt_tm, :null => false
          t.datetime :end_dt_tm, :null => false

	  t.integer :freq_type,   :limit => 2, :null => false
	  t.integer :freq_interval,   :limit => 2
	  t.integer :freq_interval_qual
			
          t.text :details, :null => false
          t.integer :venue_id 
          t.decimal :latitude, :longitude, :null => false,  :precision => 15, :scale => 10   
	  t.integer :added_by, :null => false
          t.integer :one_week_schedule 
          t.boolean :is_expired , :default => false
     end
    create_index(:events, :title, :start_dt_tm)
    foreign_key(:events, :added_by, :users) 
    foreign_key(:events, :venue_id,  :venues)
  end

  def self.down
    drop_table :events
  end
end
