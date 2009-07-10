class Category < ActiveRecord::Base
  has_and_belongs_to_many :venues
  
  
  def self.for_venues_by_groups
    all_items = Category.find(:all, :conditions => ["group_id > ? ", 1], :order => 'group_id')
    categorized_and_grouped = {}
    categorized = {}
    in_process_group_id = 0
    all_items.each { |item|
          if (item.group_id == in_process_group_id) || in_process_group_id == 0
              in_process_group_id = item.group_id  #for the first item
              categorized[item.id] = item.name + (item.help_text ? item.help_text : "")
          else 
             categorized_and_grouped[in_process_group_id] = categorized
             categorized = {}
             #To take care of the first item in every group
             in_process_group_id = item.group_id
             categorized[item.id] = item.name + (item.help_text ? item.help_text : "")
          end
    }
    #Add the last group to the hash
    categorized_and_grouped[in_process_group_id] = categorized
    
    return categorized_and_grouped.sort
  end
  
   def self.for_events_by_groups
    all_items = Category.find(:all, :conditions => ["applies_to_event = ? ", true], :order => 'group_id')
    categorized_and_grouped = {}
    categorized = {}
    in_process_group_id = 0
    all_items.each { |item|
          if (item.group_id == in_process_group_id) || in_process_group_id == 0
              in_process_group_id = item.group_id  #for the first item
              categorized[item.id] = item.name + (item.help_text ? item.help_text : "")
          else 
             categorized_and_grouped[in_process_group_id] = categorized
             categorized = {}
             #To take care of the first item in every group
             in_process_group_id = item.group_id
             categorized[item.id] = item.name + (item.help_text ? item.help_text : "")
          end
    }
    #Add the last group to the hash
    categorized_and_grouped[in_process_group_id] = categorized
    
    return categorized_and_grouped.sort
  end
end
