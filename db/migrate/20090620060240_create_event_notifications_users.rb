require "migration_helpers" 
class CreateEventNotificationsUsers < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
	 create_table :event_notifications_users, :id => false , :force => true  do |t|
	  t.integer :user_id, :event_notification_id, :null => false
	  t.timestamps
	end
	 foreign_key(:event_notifications_users, :user_id, :users)	
	 foreign_key(:event_notifications_users, :event_notification_id, :event_notifications)
  end

  def self.down
     drop_table :event_notifications_users
  end
end
