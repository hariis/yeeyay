require "migration_helpers" 
class CreateVenueNotificationsUsers < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :venue_notifications_users, :id => false , :force => true  do |t|
      t.integer :user_id, :venue_notification_id, :null => false
      t.timestamps
    end
     foreign_key(:venue_notifications_users, :user_id, :users)	
     foreign_key(:venue_notifications_users, :venue_notification_id, :venue_notifications)
  end

  def self.down
    drop_table :venue_notifications_users
  end
end
