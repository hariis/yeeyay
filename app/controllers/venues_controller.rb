class VenuesController < ApplicationController
  include GeoKit::Geocoders
  include Geokit::Mappable
  include ERB::Util
  
  before_filter :require_user  , :only => [:new, :create, :edit, :update, :destroy] 
  before_filter :load_user, :only => [:new, :create, :edit, :update, :destroy]  
  layout :choose_layout
  
  def load_user
     @user= current_user
  end
  # GET /venues
  # G4
  # ET /venues.xml
  def index
    @venues = Venue.find(:all,  :order => "created_at desc" )
    # Create a new map object, also defining the div ("map") 
   # where the map will be rendered in the view
  @map = GMap.new("map")
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @venues }
    end
  end

  # GET /venues/1
  # GET /venues/1.xml
  def show
    @venue = Venue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @venue }
      format.js {render :partial => 'new_review_form'}
    end
  end

  # GET /venues/new
  # GET /venues/new.xml
  def new
    @venue = Venue.new
    @categories = Category.for_venues_by_groups
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @venue }
    end
  end

  # GET /venues/1/edit
  def edit
    @venue = Venue.find(params[:id])
    @categories = Category.for_venues_by_groups
  end

  # POST /venues
  # POST /venues.xml
  def create
    @venue = Venue.new(params[:venue])

    respond_to do |format|
      if @user.venues << @venue
        flash[:notice] = 'Venue was successfully created.'
        format.html { redirect_to(venue_path(@venue)) }
        format.xml  { render :xml => @venue, :status => :created, :location => @venue }
      else        
        @categories = Category.for_venues_by_groups
        format.html { render :action => "new" }
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.xml
  def update
    @venue = Venue.find(params[:id])
    @owner = @venue.created_by?(current_user)
    if @owner      
      #update the lat and lng
      if @venue.street_address != params[:venue][:street_address].to_s
         result = MultiGeocoder.geocode(params[:venue][:street_address]) if params[:venue][:street_address] != nil
         @venue.latitude, @venue.longitude = result.lat, result.lng
      end    
    end  
    respond_to do |format|
      if @owner && @venue.update_attributes(params[:venue])
        flash[:notice] = 'Venue was successfully updated.'
        format.html {  redirect_to(venue_path(@venue)) }
        format.xml  { head :ok }
      else
        @categories = Category.for_venues_by_groups
        format.html { 
          if !@owner
            flash[:notice] = "Only the member that added this venue can edit. <br/> If you feel the information is incorrect, please contact us."    
            redirect_to(venue_path(@venue))
          else
            render :action => "edit" 
          end
        }
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  
  def find
     @venues = []
    #This performs an OR query - Venues found may have one or more of the asked for categories
    #~ chosen_cats = Category.find([20,40,41])
    #~ @venues = {}
    #~ chosen_cats.each {|cat|  
        #~ cat.venues.each {|venue|
        #~ @venues[venue] = ""
        #~ }
         
    #~ }
    #This performs an AND query 
    #~ @venues = Venue.find_by_sql "SELECT venues.* FROM venues INNER JOIN
    #~ categories_venues cv1 ON venues.id = cv1.venue_id INNER JOIN
    #~ categories_venues cv2 ON venues.id = cv2.venue_id INNER JOIN
    #~ categories_venues cv3 ON venues.id = cv3.venue_id WHERE
    #~ cv1.category_id = 41 AND cv2.category_id = 40 AND cv3.category_id = 2"
    
    #~ This performs an OR query - Venues found may have one or more of the asked for categories
    #~ @venues = Venue.find_by_sql "SELECT DISTINCT venues.* FROM venues INNER JOIN
    #~ categories_venues cv1 ON venues.id = cv1.venue_id WHERE
    #~ cv1.category_id IN (2,40, 41)"

   #Finding All Points Within a Specified Radius
   @home = MultiGeocoder.geocode(params[:zipcode]) 
    if @home   
        #Store the home as a cookie
        session[:home] = params[:zipcode]
        #Find the venues
        @zipcode = params[:zipcode]
        venues = Venue.find(:all, :origin => @home, :within => 25, :order => 'rating_avg desc' ) 
        venue_ids =venues.map { |i| i.id } if venues            
        
       #Initialize with all the venues                
       @venues = venues
                   
        #Now Filter them by the categories chosen
        @categories = ""
        category_ids = params[:venue][:category_ids] if params[:venue]
        if venue_ids.size > 0 
             #Narrow them down by the categories chosen
              if category_ids != nil                  
                    #ANDing the Categories
                    inner_join_string = ""
                    where_clause_string = " WHERE cv0.category_id = #{category_ids[0]}"
                    category_ids.each { |cat|
                        @categories += Category.find_by_id(cat, :select => :name).name + " , "
                        inner_join_string += " INNER JOIN categories_venues cv#{category_ids.index(cat)} ON venues.id = cv#{category_ids.index(cat)}.venue_id "
                        where_clause_string += " AND cv#{category_ids.index(cat)}.category_id = #{cat}" if category_ids.index(cat) > 0
                    }

                    @venues = Venue.find_by_sql "SELECT venues.* FROM venues  #{inner_join_string}   #{where_clause_string}  AND venues.id IN (#{venue_ids.join(',')}) order by rating_avg desc limit 50"
                    @categories.chomp!(" , ")             
              end
        end
       
       if @zipcode && @venues.size < 50
              #Fill up the map
              fill_map
       else
             #If there are more than 50 venues, then we don't want to display the map as there may be some performance issues
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
      format.xml   { render :xml => @venues } 
      format.js {render :partial => 'find', :locals => {:venues => @venues }}
    end
    
       #OR ing the Categories
#   @venues = Venue.find_by_sql "SELECT DISTINCT venues.* FROM venues INNER JOIN
#    categories_venues cv1 ON venues.id = cv1.venue_id WHERE
#    cv1.category_id IN (40, 41) AND venues.id IN (#{venue_ids.join(',')})" 
    
#    @venues = Venue.find_by_sql "SELECT venues.* FROM venues INNER JOIN
#          categories_venues cv1 ON venues.id = cv1.venue_id INNER JOIN
#          categories_venues cv2 ON venues.id = cv2.venue_id INNER JOIN
#          categories_venues cv3 ON venues.id = cv3.venue_id WHERE
#          cv1.category_id = 41 AND cv2.category_id = 40 AND cv3.category_id = 2"
    
  end
  
  def rate
    @venue = Venue.find(params[:id])
    rating= params[:rate].to_i
    @venue.rate(rating, current_user)

    respond_to do |format|
      format.html { redirect_to venue_path(@venue) }
      format.xml  { head :ok }
      format.js
    end

  end
  def save_to_list
    @saved_venue = params[:id] ? Venue.find_by_id(params[:id]) : nil
    if @saved_venue
        @saved_venue_entry = SavedVenue.new(:user_id => current_user.id, :venue_id => @saved_venue.id)
        @saved_venue_entry.save
    end  
    @venues = current_user.venues_to_visit      
    respond_to do |format|        
        format.js
    end
    
  end
  def remove_from_list      
    if params[:saved_venue_id] != nil
      SavedVenue.remove_from_list(params[:saved_venue_id],nil,current_user)
    else
      SavedVenue.remove_from_list(nil, params[:venue_id],current_user)
    end
    @remove = params[:remove] != nil
    @saved_venue = Venue.find_by_id(params[:venue_id])
    @venues = current_user.venues_to_visit  
    respond_to do |format|        
        format.js
    end 
  end
  
  def saved_venues
    @venues = current_user.venues_to_visit  
    @zipcode = session[:home]|| "portland,or"
    @home = MultiGeocoder.geocode(@zipcode)     
    fill_map
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @venues }
    end
  end
  
  def notify
    #Save the query first
    #is query valid TODO
    if params[:query_id] != nil && params[:query_id] != ""
      #is this query string already saved
      found  = VenueNotification.find_by_query_id(params[:query_id])  
      if (!found)
            found = VenueNotification.create(:query_id => params[:query_id], :last_count => params[:count])
      end
    end
    #Save the subscribe info
    current_user.venue_notifications << found
    
      render :update do |page|                           
	    page.replace_html 'notify', "Done. <br/>You will be notified when more venues are added that matches your query."
       end   
  end
  
   def share
                #validate the email addresses, if any, before attempting to save 
                #send emails
                @venue = Venue.find_by_id(params[:id])
                @venue.emails = params[:venue][:emails]
                @venue.comments = params[:comments]
                if @venue.emails.length > 0
                      if validate_emails(@venue.emails) 
                              #now send emails
                              @venue.share_venue(current_user) 
                              @status_message = "<div id='success'>Venue shared with your friends.</div>"
                              
                      else
                              @status_message = "<div id='failure'>There was a problem sharing. <br/>" + @invalid_emails_message + "</div>"
                              
                      end
                else
                          @status_message = "<div id='failure'>One or more of the email addresses is invalid. <br/> Please check and try again.</div>"
                 end		  
       
      end
  private
  def fill_map
       #Set the map
       @map = GMap.new("map")          
        # Use the larger pan/zoom control but disable the map type selector
      @map.control_init(:large_map => true,:map_type => false)
      #Plot all the venues on the map    
      for venue in @venues 
        if @home
        info = (<<EOS
<b>#{venue.name}</b><br/><br/><em>#{venue.street_address}</em><br/><br/><br/><a href="http://maps.google.com/maps?saddr=#{u(@home.to_geocodeable_s)}&daddr=#{u(venue.street_address)}>Get Directions</a>                    
EOS
    )    
        else
          info = (<<EOS
<b>#{venue.name}</b><br/><br/><em>#{venue.street_address}</em><br/><br/><br/>                   
EOS
    )    
        end
             @map.overlay_init(GMarker.new([venue.latitude,venue.longitude],  :title => venue.name,   :info_window => info))    
      end
    #Plot the Home
    if @home
      @map.overlay_init(GMarker.new([@home.lat,@home.lng],  :title => "Home",   :info_window => "#{"<b>HOME</b>" + "<br/><br/>" + @zipcode }")) 
      #Zoom the map centering on the Home
      @map.center_zoom_init([@home.lat,@home.lng], 10)  
    end
  end
  # DELETE /venues/1
  # DELETE /venues/1.xml
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to(venues_url) }
      format.xml  { head :ok }
    end
  end
  def choose_layout    
    if [ 'new', 'edit','create','update', 'destroy', 'show','rate','saved_venues' ].include? action_name
      'venues'
    elsif ['find'].include? action_name
    'eventsjq'    
    else
      'application'  #the one with search tabs
    end
  end
end
