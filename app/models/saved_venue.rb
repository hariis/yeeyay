class SavedVenue < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue
  
  def self.remove_from_list(entry_id,venue_id,current_user)
    SavedVenue.find_by_id(entry_id).destroy if entry_id
    SavedVenue.find(:first, :conditions => ['venue_id = ? and user_id = ?',venue_id, current_user.id] ).destroy if venue_id
  end
end
