class SavedEvent < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  
  def self.remove_from_list(entry_id,event_id,current_user)
    SavedEvent.find_by_id(entry_id).destroy if entry_id
    SavedEvent.find(:first, :conditions => ['event_id = ? and user_id = ?',event_id, current_user.id] ).destroy if event_id
  end
end
