 class MailingJob  
   attr_accessor :venue_id, :current_user_id
   def initialize(venue,current_user)
     self.venue_id = venue.id
     self.current_user_id = current_user.id
   end
   def perform
     #@venue.share_venue(@current_user)
     venue = Venue.find(venue_id)
     current_user = User.find(current_user_id)
     Notifier.deliver_share_venue(venue,current_user)
   end
 end
