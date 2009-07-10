class User < ActiveRecord::Base
  acts_as_authentic
  has_many :venues, :foreign_key => :added_by
  has_many :venue_submissions , :class_name => :venues
  has_many :saved_venues
  has_many :venues_to_visit, :source => :venue,:through => :saved_venues, :uniq => true
  has_many :saved_events
  has_many :events_to_visit, :source => :event,:through => :saved_events, :uniq => true
  has_many :venue_reviews
  has_many :user_roles, :dependent => :destroy  
  has_many :roles, :through => :user_roles
  has_and_belongs_to_many :venue_notifications
  has_and_belongs_to_many :event_notifications
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end
  def has_role?(role)
    self.roles.count(:conditions => ['name = ?', role]) > 0
  end

  def add_role(role)
    return if self.has_role?(role)
    self.roles << Role.find_by_name(role)
  end
  
  def is_subscribed_to_venues(query_id)
    notification  = Notification.find_by_query_id(query_id) 
    if notification
      if notification.users.find(id) != nil
	return true
      end
    end
    return false
  end
  
  def is_subscribed_to_events(query_id)
    notification  = EventNotification.find_by_query_id(query_id) 
    if notification
      if notification.users.find(id) != nil
	return true
      end
    end
    return false
  end
end
