# Load modules and classes needed to automatically mix in ActiveRecord and 
# ActionController helpers.  All other functionality must be explicitly 
# required.
require 'geokit' #requires the geokit gem
require 'defaults'
require 'acts_as_mappable'
require 'ip_geocode_lookup'

# Automatically mix in distance finder support into ActiveRecord classes.
ActiveRecord::Base.send :include, GeoKit::ActsAsMappable

# Automatically mix in ip geocoding helpers into ActionController classes.
ActionController::Base.send :include, GeoKit::IpGeocodeLookup
