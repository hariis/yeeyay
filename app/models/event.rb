class Event < ActiveRecord::Base
  acts_as_mappable  :lat_column_name => 'latitude',:lng_column_name => 'longitude'
  include Schedulehelper
  acts_as_rated(:rating_range => 1..5)
  attr_accessor :venue_name
  attr_accessor :dup_event
  belongs_to :user, :foreign_key => :added_by
  belongs_to  :venue
  has_and_belongs_to_many :categories
  has_many :event_reviews
  has_many :saved_events
  has_many :visitors, :source => :user, :through => :saved_events, :uniq => true
  
  validates_presence_of :title, :message => "Please enter a Title"
  validates_presence_of :details, :message => "Please tell us a little bit about this event"
  validates_length_of   :details, :maximum => 1000, :message => "Details exceeded limit of 1000 characters", :if => Proc.new{|event| event.details && event.details.size != 0}
  validates_presence_of :venue_id, :message => "Please tell us where is this event going to be held"
  
  before_save  :flag_for_pickup 
  
  validates_each :start_dt_tm , :on => :save do |record,attr,value| 
        if value > record.end_dt_tm then
            record.errors.add(attr,"Please check the End Date!")
        end      
  end
  
  #This check has to happpen only on creation. No need during update
  validates_each :venue_id ,:if => :event_already_exists?, :on => :create do |record,attr,value| 
         record.errors.add(attr,": This Event already exists. <br/>
          Please Check it out. <br/><br/> ")           
  end
  attr_accessor :emails, :comments
  def event_already_exists?
    #Event is a function of title, venue and times (atleast start time)
    @event_exists = Event.find(:first, :conditions => ['title = ? and start_dt_tm = ? and venue_id = ?',title.strip, start_dt_tm, venue_id])
    if @event_exists != nil
      self.dup_event = @event_exists
      return true
    else
      return false
    end
  end
  
  def venue_name
    venue ? venue.name : ""
  end
  def created_by?(a_user)
    self.user.id == a_user.id
  end
  def is_saved_by(a_user)
    SavedEvent.find(:first, :conditions => ['user_id = ? and event_id = ?', a_user, id]) #if not_owner
  end
  def can_write_review(a_user)
     #not_owner = !self.created_by?(a_user) 
     reviewed_already = EventReview.find(:first, :conditions => ['added_by = ? and event_id = ?', a_user, id]) #if not_owner    
     reviewed_already == nil  
  end
  
  def self.recommended_by(a_user)
    events = Rating.find(:all, :conditions => ['rater_id = ? and rating >= ?', a_user.id, 4], :select => 'rated_id', :order => 'rating desc', :limit => 5)
    return events if events.size == 0
    
    event_ids = events.collect { |i| i.rated_id }  
    event_ids_string = event_ids.join(',')
    Event.find_by_sql "SELECT id,title,details FROM events WHERE id IN (#{event_ids_string})"
    
  end
  def self.added_by(a_user)
    Event.find(:all, :conditions => ['added_by = ?', a_user.id]) 
  end
  
  def created_by?(a_user)
    self.user.id == a_user.id
  end

  #These filters are called after both creating new and updating existing entries
  def flag_for_pickup  
      self.one_week_schedule = 0 #Start clean
      0.upto(7) do |idx|
        if (start_dt_tm.to_date <= Time.zone.now.to_date + idx) && (end_dt_tm.to_date >= Time.zone.now.to_date + idx)
          if Schedulehelper.IsEntryDueOn(self, Time.zone.now.to_date + idx)
              self.one_week_schedule  |= (1 << idx)  
          end
        end
      end
  end
 
  def update_venue
    venue_exists = Venue.find(:first, :conditions => ['latitude BETWEEN ? and ? and longitude BETWEEN ? and ?',latitude - 0.5,latitude + 0.5,longitude - 0.5, longitude + 0.5])
    self.venue_id = venue_exists.id if venue_exists
  end

  def self.get_one_week_calendar_for(selected_events)
    calendar = {}
    today = calendar_date = Time.zone.now.to_date
    day = 0
    while calendar_date <= today + 7 do
      qualified_events = []
      selected_events.each do |e|        
        if e.one_week_schedule[day] == 1  then
                qualified_events << e               
        end	
      end
      calendar[calendar_date] = qualified_events
      calendar_date+= 1
      day +=1
    end
    return calendar.sort
  end
  
  #Needs to be called by the cron job
  def self.update_one_week_schedule  
       #Find those events that have expired but whose flag is not set yet
       live_events = Event.find(:all, :conditions => ["is_expired = ? and end_dt_tm < ?", false, Time.zone.now.utc])      
       
      #Now set that flag    
      live_events.each {|event| event.update_attributes(:is_expired => true, :one_week_schedule => 0)}    
      
            
       current_live_events = Event.find(:all, :conditions => ['is_expired = ? ', false])  
       current_live_events.each do |event|
           #Shift the 7-day range by a day
           event.one_week_schedule  = (event.one_week_schedule >> 1)
	   if (event.start_dt_tm.to_date <= Time.zone.now.to_date + 7) && (event.end_dt_tm.to_date >= Time.zone.now.to_date + 7)
              if Schedulehelper.IsEntryDueOn(event, Time.zone.now.to_date + 7)                  
                  event.one_week_schedule  |= (1 << 7)               
              end              
            end
            event.update_attribute(:one_week_schedule , event.one_week_schedule)
       end  
  end
  
  def display_categories
    categories && categories.size > 0 ? categories.collect{|t| t.name}.to_sentence : ""
  end
  
  def self.find_events(query_id)
    #Finding All Points Within a Specified Radius
    items = query_id.split('+')  if query_id != "" 
    zipcode = items[0]
    category_ids = []
    1.upto(items.size - 1) { |i| category_ids << i }

    home = MultiGeocoder.geocode(zipcode) 
    events = Event.find(:all, :origin => home, :within => 25, :order => 'rating_avg desc' ) 
    event_ids = events.map { |i| i.id } if events  
    
    if category_ids != nil                  
	  #ANDing the Categories
	  inner_join_string = ""
	  where_clause_string = " WHERE cv0.category_id = #{category_ids[0]}"
	  category_ids.each { |cat|	      
	      inner_join_string += " INNER JOIN categories_events cv#{category_ids.index(cat)} ON events.id = cv#{category_ids.index(cat)}.event_id "
	      where_clause_string += " AND cv#{category_ids.index(cat)}.category_id = #{cat}" if category_ids.index(cat) > 0
	  }

	  events = Event.find_by_sql "SELECT events.* FROM events  #{inner_join_string}   #{where_clause_string}  AND events.id IN (#{event_ids.join(',')}) order by rating_avg desc limit 50"
	           
    end
    return events
  end
  
   def share_event(sent_by)
		Notifier.deliver_share_event(self,sent_by)
   end
end
