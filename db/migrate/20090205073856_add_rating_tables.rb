class AddRatingTables < ActiveRecord::Migration
    def self.up
      ActiveRecord::Base.create_ratings_table

      Venue.add_ratings_columns
    end
    
    def self.down
      # Remove the columns we added
      Venue.remove_ratings_columns
      ActiveRecord::Base.drop_ratings_table
    end
  end  