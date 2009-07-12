require "migration_helpers" 
class CreateUsersVenueNotifications < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :users_venue_notifications, :id => false , :force => true  do |t|
      t.integer :user_id, :venue_notification_id, :null => false
      t.timestamps
    end
     foreign_key(:users_venue_notifications, :user_id, :users)	
     foreign_key(:users_venue_notifications, :venue_notification_id, :venue_notifications)
  end

  def self.down
    drop_table :users_venue_notifications
  end
end
