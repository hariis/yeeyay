class CreateVenueNotifications < ActiveRecord::Migration
  def self.up
    create_table :venue_notifications do |t|
      t.string :query_id
      t.integer :last_count
      t.timestamps
    end
  end

  def self.down
    drop_table :venue_notifications
  end
end
