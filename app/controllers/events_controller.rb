class EventsController < ApplicationController
  include GeoKit::Geocoders
  include Geokit::Mappable
  include ERB::Util
  
  before_filter :require_user  , :except => [:index, :show, :find ]   #, :only => [:new, :create, :edit, :update, :destroy] 
  before_filter :load_user   , :except => [:index, :show, :find ]      #, :only => [:new, :create, :edit, :update, :destroy]
  layout :choose_layout
  
  def load_user
     @user= current_user
  end
  
  # GET /events
  # GET /events.xm6.l
  def index    
    #Show Search form
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
     @event = flash[:event] || Event.new
     @categories = Category.for_events_by_groups
     @freqtypes = Schedulehelper::FREQ_TYPES
     load_frequency_data if flash[:event]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = flash[:event] || Event.find(params[:id])
    @categories = Category.for_events_by_groups
    @freqtypes = Schedulehelper::FREQ_TYPES
    load_frequency_data
  end
  def load_frequency_data
    if  @event.freq_type == 1 
         @freqintervals = nil
     elsif  @event.freq_type   == 6 then
          @freqintervals = Schedulehelper::FREQ_INTERVALS_DAILY
    elsif @event.freq_type   == 7 then
          @freqintervals = Schedulehelper::FREQ_INTERVALS_WEEKLY
          @freqintervalsqual= Schedulehelper::FREQ_INTERVALS_QUAL_WEEKLY
    elsif @event.freq_type   == 8 then
          @freqintervals = Schedulehelper::FREQ_INTERVALS_MONTHLY
          @freqintervalsqual= Schedulehelper::FREQ_INTERVALS_QUAL_DATE
    elsif @event.freq_type   == 9 then
          @freqintervals = Schedulehelper::FREQ_INTERVALS_MONTHLY
          @freqintervalsqual= Schedulehelper::FREQ_INTERVALS_QUAL_DAY
    end
    @start = @event.start_dt_tm
    @end = @event.end_dt_tm
    @freq_interval_selected = @event.freq_interval
    
    if (@event.freq_interval_qual)
      selectedvalues = Schedulehelper::ExtractFreqIntQualIntoArr(@event.freq_interval_qual,true)   
      @freqintervalsqual_selected = []
      selectedvalues.each{|val|@freqintervalsqual_selected << val.to_s }		  
    end
  end
  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    
    @event.start_dt_tm = Time.zone.parse(params[:start]).at_beginning_of_day.utc
    @event.end_dt_tm = params[:end] != nil ? Time.zone.parse(params[:end]).at_beginning_of_day.utc : @event.start_dt_tm
    
    @event.freq_interval = params[:freq_interval] if (params[:freq_interval] != nil) 

      if (params[:freq_interval_details] != nil) then
	fix = 0b1
	@event.freq_interval_qual = 0

	params[:freq_interval_details].collect{|char| @event.freq_interval_qual |= fix << ((char.to_i)-1) } 
      end
   @event.added_by = current_user.id
   if params[:event][:venue_name] != nil && !params[:event][:venue_name].blank?
         venue = Venue.find_by_name(params[:event][:venue_name].strip)
         @event.venue_id = venue.id
         @event.latitude = venue.latitude
         @event.longitude = venue.longitude
   else
        @event.venue_id = nil
   end
    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else          
        @categories = Category.for_events_by_groups
        @freqtypes = Schedulehelper::FREQ_TYPES
        format.html {
          if @event.dup_event != nil
            render :action => "dup_event_notification" 
          else
            flash[:event] = @event
            redirect_to(new_event_path)
          end
        }  
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    @owner = @event.created_by?(current_user)  
    if @owner
        @event.start_dt_tm = Time.zone.parse(params[:start]).at_beginning_of_day.utc
        @event.end_dt_tm = params[:end] != nil ? Time.zone.parse(params[:end]).at_beginning_of_day.utc : @event.start_dt_tm

        @event.freq_interval = params[:freq_interval] if (params[:freq_interval] != nil) 

        if (params[:freq_interval_details] != nil) then
          fix = 0b1
          @event.freq_interval_qual = 0

          params[:freq_interval_details].collect{|char| @event.freq_interval_qual |= fix << ((char.to_i)-1) } 
        end
        #Do we store who updated it?

       if params[:event][:venue_name] != nil && !params[:event][:venue_name].blank?
            if @event.venue.name != params[:event][:venue_name] #If venue has not changed, no need to recheck and repopulate
                @event.venue_id = Venue.find_by_name(params[:event][:venue_name].strip).id
            end
       else
            @event.venue_id = nil
       end
    end
   
    respond_to do |format|
      if @owner && @event.update_attributes(params[:event])
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        @categories = Category.for_events_by_groups
        @freqtypes = Schedulehelper::FREQ_TYPES
        load_frequency_data
        format.html { 
          if !@owner
            flash[:notice] = "Only the member that added this event can edit. <br/> If you feel the information is incorrect, please contact us."    
            redirect_to(@event)
          else
            render :action => "edit" 
          end
        }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def rate
    @event = Event.find(params[:id])
    rating= params[:rate].to_i
    @event.rate(rating, current_user)

    respond_to do |format|
      format.html { redirect_to event_path(@event) }
      format.xml  { head :ok }
      format.js
    end

  end
 
  def find
    @events = []
    #Finding All Points Within a Specified Radius
    @home = MultiGeocoder.geocode(params[:zipcode]) 
    if @home   
        #Find the events
        @zipcode = params[:zipcode]
        events = Event.find(:all, :origin => @home, :within => 25, :conditions => ['one_week_schedule > ?',0], :order => 'rating_avg desc', :include => 'venue' ) 
        event_ids =events.map { |i| i.id } if events            
        
       #Initialize with all the events                
       @events = events
                   
        #Now Filter them by the categories chosen
        @categories = ""
        if event_ids.size > 0 
             #Narrow them down by the categories chosen
             category_ids = params[:event][:category_ids] if params[:event]

              if category_ids != nil                  
                    #ANDing the Categories
                    inner_join_string = ""
                    where_clause_string = " WHERE cv0.category_id = #{category_ids[0]}"
                    category_ids.each { |cat|
                        @categories += Category.find_by_id(cat, :select => :name).name + " , "
                        inner_join_string += " INNER JOIN categories_events cv#{category_ids.index(cat)} ON events.id = cv#{category_ids.index(cat)}.event_id "
                        where_clause_string += " AND cv#{category_ids.index(cat)}.category_id = #{cat}" if category_ids.index(cat) > 0
                    }

                    @events = Event.find_by_sql "SELECT events.* FROM events  #{inner_join_string}   #{where_clause_string}  AND events.id IN (#{event_ids.join(',')}) order by rating_avg desc limit 50"
                    @categories.chomp!(" , ")             
              end
        end
       if @zipcode && @events.size > 0
         @events_calendar = Event.get_one_week_calendar_for(@events)
       end
      
      
       if @zipcode && @events.size < 50
              fill_map
       else
             #If there are more than 50 events, then we don't want to display the map as there may be some performance issues
             @map = nil
       end    
       
       #store an identifiable string for this query    
	if category_ids != nil       
	    @query_id = @zipcode + "+" + category_ids.join('+') 
	else
	  @query_id = @zipcode
	end
    end   
    respond_to do |format|
        format.html 
        format.xml  { head :ok }
        format.js {render :partial => 'find', :locals => {:events => @events }}
    end
  end
  def fill_map
    #Set the map
    @map = GMap.new("map")          
    # Use the larger pan/zoom control but disable the map type selector
    @map.control_init(:large_map => true,:map_type => false)
    #Plot all the events on the map    
    @events.each do |event|      
    info = (<<EOS
<b>#{event.title}</b><br/><br/><em>#{event.venue.full_address}</em><br/><br/><br/><a href="http://maps.google.com/maps?saddr=#{u(@home.to_geocodeable_s)}&daddr=#{u(event.venue.full_address)}>Get Directions</a>                    
EOS
)                         
         @map.overlay_init(GMarker.new([event.latitude,event.longitude],  :title => event.title,   :info_window => info))    
  end
    #Plot the Home
    @map.overlay_init(GMarker.new([@home.lat,@home.lng],  :title => "Home",   :info_window => "#{"<b>HOME</b>" + "<br/><br/>" + @zipcode }")) 
    #Zoom the map centering on the Home
    @map.center_zoom_init([@home.lat,@home.lng], 10)     
  end
  def flag
    Event.update_one_week_schedule
  end
  def auto_complete_for_entry_tag_list
        auto_complete_for_tag_list
  end
  def auto_complete_for_event_venue_name
    @venues = []    
    keyword = params[:event][:venue_name]
    unless keyword.blank?
          criteria = '%' + keyword.downcase.strip + '%'
          @venues  = Venue.find(:all, :conditions=>["LOWER(name) LIKE ?",criteria])
    end
    render :partial => "autocomplete_venue_id"
  end
  def auto_complete_belongs_to_for_event_venue_name
    @venues = Venue.find(
      :all,
      :conditions => ['LOWER(name) LIKE ?', "%#{params[:venue][:name]}%"],
      :limit => 10
    )
    render :inline => '<%= model_auto_completer_result(@venues, :name) %>'
  end

  def save_to_list
    @saved_event = params[:id] ? Event.find_by_id(params[:id]) : nil
    if @saved_event
        @saved_event_entry = SavedEvent.new(:user_id => current_user.id, :event_id => @saved_event.id)
        @saved_event_entry.save
    end  
    @events = current_user.events_to_visit    
    respond_to do |format|        
        format.js
    end
    
  end
  def remove_from_list      
    if params[:saved_event_id] != nil
      SavedEvent.remove_from_list(params[:saved_event_id],nil,current_user)
    else
      SavedEvent.remove_from_list(nil, params[:event_id],current_user)
    end
    @remove = params[:remove] != nil
    @events = current_user.events_to_visit
    @saved_event = Event.find_by_id(params[:event_id])
    respond_to do |format|        
        format.js
    end 
  end
  
  def saved_events
    @events = current_user.events_to_visit  
    @zipcode = session[:home]|| "portland,or"
    @home = MultiGeocoder.geocode(@zipcode)     
    fill_map
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end
  
  def notify
    #Save the query first
    #is query valid TODO
    if params[:query_id] != nil && params[:query_id] != ""
      #is this query string already saved
      found  = EventNotification.find_by_query_id(params[:query_id])  
      if (!found)
            found = EventNotification.create(:query_id => params[:query_id], :last_count => params[:count])
      end
    end
    #Save the subscribe info
    current_user.event_notifications << found
    
      render :update do |page|                           
	    page.replace_html 'event-notify', "Done. <br/>You will be notified when more events are added that matches your query."
       end   
  end
  def share
                #validate the email addresses, if any, before attempting to save 
                #send emails
                @event = Event.find_by_id(params[:id])
                @event.emails = params[:event][:emails]
                @event.comments = params[:comments]
                if @event.emails.length > 0
                      if validate_emails(@event.emails) 
                              #now send emails
                              @event.share_event(current_user) 
                              @status_message = "<div id='success'>Event shared with your friends.</div>"
                              
                      else
                              @status_message = "<div id='failure'>There was a problem sharing. <br/>" + @invalid_emails_message + "</div>"
                              
                      end
                else
                          @status_message = "<div id='failure'>One or more of the email addresses is invalid. <br/> Please check and try again.</div>"
                 end		  
       
  end
  private
  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
    
  def choose_layout    
    if [ 'new', 'edit','create','update', 'destroy', 'show','rate','saved_events' ].include? action_name
      'events'
    elsif ['find'].include? action_name
      'eventsjq'
    else
      'application'
    end
  end
end
