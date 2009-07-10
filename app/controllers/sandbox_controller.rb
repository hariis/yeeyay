class SandboxController < ApplicationController
  include GeoKit::Mappable
  include GeoKit::Geocoders

  def lookup_geocodes
    # your list of places. In a real app, this would come from the database,
    # and have more robust descriptions
    places = [
      {:address=>'555 Irving, San Francisco, CA',:description=>'Irving'},
      {:address=>'1401 Valencia St, San Francisco, CA',:description=>'Valencia'},
      {:address=>'501 Cole St, San Francisco, CA',:description=>'Cole'},
      {:address=>'150 Church st, San Francisco, CA',:description=>'Church'} 
     ]

    # this loop will do the geo lookup for each place
    places.each_with_index do |place,index|
      # get the geocode by calling our own get_geocode(address) method
      geocode = get_geocode place[:address]
      
      # geo_code is now a hash with keys :latitude and :longitude
      # place these values back into our "database" (array of hashes)
      place[:latitude]=geocode[:latitude]
      place[:longitude]=geocode[:longitude]    
    
    end
    
    #place the result in the session so we can use it for display
    session[:places] = places
    
    #let the user know the lookup went ok
    render :text=> 'Looked up the geocodes for '+places.length.to_s+
	' address and stored the result in the session . . .'
  
  end

  def show_google_map
    # all we're going to do is loop through the @places array on the page
    @places=session[:places]
  end
  
  def distance

   # Retrieve the coordinate for Mitchell's Steakhouse
   mitchells = GoogleGeocoder.geocode("45 North Third Street,
                                       Columbus, Ohio 43215")

   # Retrieve the coordinates for the art museum
   museum = GoogleGeocoder.geocode("480 E Broad St, Columbus,
                                    Ohio 43215")

   # Retrieve the coordinates for Columbus, Ohio
   # (for map centering purposes)
   city = GoogleGeocoder.geocode("Columbus, Ohio")

   # Calculate the distance between the two locations
   @distance = mitchells.distance_from(museum)

   # Create a new map and center it on Columbus
   @map = GMap.new("map")
   @map.center_zoom_init([city.lat, city.lng], 14)

   # Add an icon denoting Mitchell's location
   mitchells_marker = GMarker.new([mitchells.lat,mitchells.lng])
   @map.overlay_init(mitchells_marker)

   # Add an icon denoting the museum's location
   museum_marker = GMarker.new([museum.lat,museum.lng])
   @map.overlay_init(museum_marker)

end



  private
  def get_geocode(address)
    logger.debug 'starting geocoder call for address: '+address
    # this is where we call the geocoding web service
    #server = XMLRPC::Client.new2('http://rpc.geocoder.us/service/xmlrpc')
    #result = server.call2('geocode', address)
    result=MultiGeocoder.geocode(address)
    logger.debug "Geocode call: "+result.inspect
    
    return {:success=> true, :latitude=> result.lat, 
		:longitude=> result.lng}
  end  
end
