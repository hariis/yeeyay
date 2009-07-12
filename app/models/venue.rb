class Venue < ActiveRecord::Base  
  acts_as_mappable :auto_geocode=>{:field=>:street_address, :error_message=>'could not be located'},  :lat_column_name => 'latitude',:lng_column_name => 'longitude'
  acts_as_rated(:rating_range => 1..5)
  
  belongs_to :user, :foreign_key => :added_by
  has_and_belongs_to_many :categories
  has_many :saved_venues
  has_many :visitors, :source => :user, :through => :saved_venues, :uniq => true
  has_many :venue_reviews
  has_many :events
  
  validates_presence_of :name, :description
  validates_format_of :url, :with => URI::regexp(%w(http https))  
  validates_each :street_address ,:if => :venue_already_exists?, :on => :create do |record,attr,value| 
         record.errors.add(attr,": This Venue already exists. <br/>
          Check it out. <br/><br/>
          If you think the information about this venue is incorrect,<br/> please contact us.")       
  end
  attr_accessor :emails, :comments
  def venue_already_exists?
    venue_exists = Venue.find(:first, :conditions => ['latitude BETWEEN ? and ? and longitude BETWEEN ? and ?',latitude - 0.05,latitude + 0.05,longitude - 0.05, longitude + 0.05])
    venue_exists != nil
  end
  def created_by?(a_user)
    self.user.id == a_user.id
  end
  
  def can_write_review(a_user)
     #not_owner = !self.created_by?(a_user) 
     reviewed_already = VenueReview.find(:first, :conditions => ['added_by = ? and venue_id = ?', a_user, id]) #if not_owner       
     reviewed_already == nil  
  end
  
  def is_saved_by(a_user)
    SavedVenue.find(:first, :conditions => ['user_id = ? and venue_id = ?', a_user, id]) #if not_owner
  end
  
  def self.recommended_by(a_user)
    venues = Rating.find(:all, :conditions => ['rater_id = ? and rating >= ?', a_user.id, 4], :select => 'rated_id', :order => 'rating desc', :limit => 5)
    return venues if venues.size == 0
    
    venue_ids = venues.collect { |i| i.rated_id }  
    venue_ids_string = venue_ids.join(',')
    Venue.find_by_sql "SELECT id,name,description,street_address FROM venues WHERE id IN (#{venue_ids_string})"
    
  end
  def self.added_by(a_user)
    Venue.find(:all, :conditions => ['added_by = ?', a_user.id]) 
  end
  
  def display_categories
    categories && categories.size > 0  ? categories.collect{|t| t.name}.to_sentence : ""
  end
  
  def display_name
    name.titleize
  end
  
  def self.find_venues(query_id)
    #Finding All Points Within a Specified Radius
    items = query_id.split('+')  if query_id != "" 
    zipcode = items[0]
    category_ids = []
    1.upto(items.size - 1) { |i| category_ids << i }

    home = MultiGeocoder.geocode(zipcode) 
    venues = Venue.find(:all, :origin => home, :within => 25, :order => 'rating_avg desc' ) 
    venue_ids = venues.map { |i| i.id } if venues  
    
    if venue_ids.size > 0 
         #Narrow them down by the categories chosen
          if category_ids != nil  &&   category_ids.size != 0          
                #ANDing the Categories
                inner_join_string = ""
                where_clause_string = " WHERE cv0.category_id = #{category_ids[0]}"
                category_ids.each { |cat|                    
                    inner_join_string += " INNER JOIN categories_venues cv#{category_ids.index(cat)} ON venues.id = cv#{category_ids.index(cat)}.venue_id "
                    where_clause_string += " AND cv#{category_ids.index(cat)}.category_id = #{cat}" if category_ids.index(cat) > 0
                }
                venues = Venue.find_by_sql "SELECT venues.* FROM venues  #{inner_join_string}   #{where_clause_string}  AND venues.id IN (#{venue_ids.join(',')}) order by rating_avg desc limit 50"
          end
    end
    return venues
  end  
  
  #Needs to be called by the cron job
  def self.notify_subscribers
    #Find the queries that got impacted and Find the subscribers of each query
    notifications = {}
    VenueNotification.find(:all).each do |notification|
	    current_count = Venue.find_venues(notification.query_id)
	    if current_count > notification.last_count
	      notification.users.each do |user|		
		 queries = notifications[user]
		 if queries
		      queries << transform_id_to_name(notification.query_id)
		 else
		      queries = [transform_id_to_name(notification.query_id)]		      
                 end
		 notifications[user] = queries
              end
	      
	      notification.last_count = current_count
	      notification.save
            end
    end
    
    #Notify 
    notifications.each do |user, queries|      
      Notifier.deliver_notify_subscriber(user,queries)
    end
    
  end
  
  def transform_id_to_name(query_id)
    category_ids = []
      items = query_id.split('+')  if query_id != "" 
       1.upto(items.size - 1) { |i| category_ids << i }
       categories = ""
       cat_url = ""
       if category_ids != nil                      
	    category_ids.each { |cat|
		categories += Category.find_by_id(cat, :select => :name).name + "+"
		cat_url += "&" + "venue[category_ids][]=" + cat  
	    }
	    cat_url = "http://" + default_url_options[:host] + "/venues/find?zipcode=" + items[0] + cat_url
	    return items[0] + "+" + categories + "+" + cat_url
	else
	    cat_url = "http://" + default_url_options[:host] + "/venues/find?zipcode=" + items[0]
	    return items[0] + "+" + cat_url
	end
  end
  
  def share_venue(sent_by)
		Notifier.deliver_share_venue(self,sent_by)
   end
end
