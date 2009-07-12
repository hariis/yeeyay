class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories, :force => true   do |t|
      t.string :name, :help_text
      t.integer :group_id
      t.boolean :applies_to_event, :default => true
      t.timestamps
    end

    Category.create :name => "Expo / Show", :group_id => 1
    Category.create :name => "Concert", :group_id => 1
    Category.create :name => "County / State Fair", :group_id => 1 
    Category.create :name => "Contest", :group_id => 1
    Category.create :name => "Camp", :group_id => 1
    Category.create :name => "Workshop", :group_id => 1
    
     Category.create :name => "Acting / Theatre", :group_id => 2 
    Category.create :name => "Arts & Crafts", :group_id => 2 
    Category.create :name => "Cooking", :group_id => 2    
    Category.create :name => "Language", :group_id => 2      
    Category.create :name => "Music", :group_id => 2     
    Category.create :name => "Science & Technology", :group_id => 2         
    
    Category.create :name => "Indoor Physical Activity", :group_id => 3    
    Category.create :name => "Outdoors", :group_id => 3       
    Category.create :name => "Martial Arts", :group_id => 3    
    Category.create :name => "Movement / Dance / Gymnastics", :group_id => 3    
    Category.create :name => "Park / Playground", :group_id => 3, :applies_to_event =>  false
    Category.create :name => "Public Space", :group_id => 3, :applies_to_event =>  false
    Category.create :name => "Sports", :group_id => 3  
    
    Category.create :name => "Animals", :group_id => 4 , :help_text => " (Petting Zoos, Safari etc.)"
    Category.create :name => "Educational", :group_id => 4 , :help_text => " (Museums, Arboretums, Aquariums, Zoos etc.)"
    Category.create :name => "Nature", :group_id => 4 , :help_text => " (National Parks, Apple Farms, Trails etc.)"
    
    Category.create :name => "Eatery / Restaurant / Bakery", :group_id => 5, :applies_to_event =>  false
    Category.create :name => "Clothing & Accessories", :group_id => 5, :applies_to_event =>  false
    Category.create :name => "Footwear", :group_id => 5, :applies_to_event =>  false
    Category.create :name => "Toy Store", :group_id => 5, :applies_to_event =>  false
    Category.create :name => "Hobbies", :group_id => 5, :help_text => " (Comics, Videogames, Train sets, Cards etc.)"
    Category.create :name => "Grooming", :group_id => 5, :applies_to_event =>  false
    Category.create :name => "Party Supplies", :group_id => 5, :applies_to_event =>  false
    
    Category.create :name => "Charity Organization" , :group_id => 6   
    Category.create :name => "School" , :group_id => 6
    Category.create :name => "Tutoring Service" , :group_id => 6
    Category.create :name => "Library" , :group_id => 6
    Category.create :name => "Child care / Day care" , :group_id => 6, :applies_to_event =>  false
    Category.create :name => "Health Care" , :group_id => 6, :applies_to_event =>  false
    Category.create :name => "Adoption Agency" , :group_id => 6, :applies_to_event =>  false
    
    Category.create :name => "Entertainer", :group_id => 7 , :help_text => " (Clowns, Puppeteers, Face Painters etc.)"
    Category.create :name => "Babysitter", :group_id => 7, :applies_to_event =>  false     
    
    Category.create :name => "Vacation Spot" , :group_id => 8, :applies_to_event =>  false  
    Category.create :name => "Hotel", :group_id => 8, :applies_to_event =>  false  
    Category.create :name => "Amusement Park", :group_id => 8, :applies_to_event =>  false  
    
    Category.create :name => "Eco-friendly", :group_id => 9, :applies_to_event =>  false    
    Category.create :name => "Special Needs", :group_id => 9, :applies_to_event =>  false  
    Category.create :name => "Volunteer Ops Available", :group_id => 9, :applies_to_event =>  false  
    
    Category.create :name => "0 - 12 months", :group_id => 10
    Category.create :name => "12 - 24 months", :group_id => 10
    Category.create :name => "2 - 3 years", :group_id => 10
    Category.create :name => "3 - 5 years", :group_id => 10
    Category.create :name => "5 - 7 years", :group_id => 10
    Category.create :name => "7 - 10 years", :group_id => 10
    Category.create :name => "10 - 12 years", :group_id => 10
    Category.create :name => "12+", :group_id => 10
    Category.create :name => "High School Students", :group_id => 10     
    
    Category.create :name => "Birthday Venue", :group_id => 11, :applies_to_event =>  false
    Category.create :name => "Field Trip Venue", :group_id => 11, :applies_to_event =>  false
  end

  def self.down
    drop_table :categories
  end
end
