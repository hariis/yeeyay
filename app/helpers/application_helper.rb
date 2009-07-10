# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def logged_in?
    current_user != nil
  end
  def star_rating(rating, obj_type, id, allow_rate= true)
    per= rating > 0 ? (rating/5.0)*100 : 0;
    url_meth= "rate_#{obj_type}_path".to_sym
    if allow_rate
      links= [
        link_to('1', send(url_meth, {:id => id, :rate => 1}), :method => :put, :class => "one-star", :title =>"1 star out of 5"),
        link_to('2', send(url_meth, {:id => id, :rate => 2}), :method => :put, :class => "two-stars", :title =>"2 stars out of 5"),
        link_to('3', send(url_meth, {:id => id, :rate => 3}), :method => :put, :class => "three-stars", :title =>"3 stars out of 5"),
        link_to('4', send(url_meth, {:id => id, :rate => 4}), :method => :put, :class => "four-stars", :title =>"4 stars out of 5"),
        link_to('5', send(url_meth, {:id => id, :rate => 5}), :method => :put, :class => "five-stars", :title =>"5 stars out of 5")]
#        links= [
#            link_to_remote('1', :url => send(url_meth, {:id => id, :rate => 1}), :method => :put, :html => {:class => "one-star", :title =>"1 star out of 5"}),
#            link_to_remote('2',:url =>  send(url_meth, {:id => id, :rate => 2}), :method => :put, :html => {:class => "two-stars", :title =>"2 stars out of 5"}),
#            link_to_remote('3', :url => send(url_meth, {:id => id, :rate => 3}), :method => :put, :html => {:class => "three-stars", :title =>"3 stars out of 5"}),
#            link_to_remote('4', :url => send(url_meth, {:id => id, :rate => 4}), :method => :put, :html => {:class => "four-stars", :title =>"4 stars out of 5"}),
#            link_to_remote('5', :url => send(url_meth, {:id => id, :rate => 5}), :method => :put, :html => {:class => "five-stars", :title =>"5 stars out of 5"})]
    end

    r= " "
    r += "<span class=\"inline-rating\">  <ul class=\"star-rating\"> <li class=\"current-rating\" style=\"width:#{per}%;\"></li>"

    # if we can't rate then just show stars
    if allow_rate
      (0..4).each do |i|
        r += "<li>#{links[i]}</li>"
      end
    end

    r += "</ul></span>"
   
    r
  end

  def render_rating(o, allow_rating=true)  
    #can_rate= allow_rating && logged_in? && ! o.created_by?(current_user) && ! o.rated_by?(current_user)
    can_rate= allow_rating && logged_in? &&  ! o.rated_by?(current_user)
    o_type= o.class.to_s.downcase
    
          if o.rated?
                r =    '<span class="rating-display">'
                #r += "Rating #{o.rating_average}/5 by #{pluralize(o.rated_count, 'person')}"
                #
                r += "Ave. Rating from #{pluralize(o.rated_count, 'person')}"
                 r += '</span>'
                r += star_rating(o.rating_average, o_type, o.id, can_rate)
          else 
                r = "<i>Not yet Rated</i>"
                r += star_rating(0, o_type, o.id, can_rate)          
          end
          
          if can_rate
            r += "<span  id='prompt_#{o.id}' class='prompt'>Rate this</span>" 
          else
            r += "<span  id='prompt_#{o.id}' class='prompt'></span>"   #Write this element out, so that it can be populated later
          end
    r
  end
  
  def render_individual_rating(o, user)
      rating_record = Rating.find_by_rater_id_and_rated_id(user.id, o.id)
      rating = rating_record ? rating_record.rating : nil
      if rating
          per= rating > 0 ? (rating/5.0)*100 : 0;
          r= " "
          r += "<span class=\"inline-rating\">  <ul class=\"star-rating\"> <li class=\"current-rating\" style=\"width:#{per}%;\"></li>"

          r += "</ul></span>"
      else
        r = "<i>  Not yet Rated</i>"
      end
  end
  
  def display_schedule(item)
        display = ""
        if (item.freq_type > 0 && item.freq_type < 6)  
            display << "On:  #{(item.start_dt_tm).to_date.to_s(:long) }"
         elsif item.freq_type == 6 
            display << "#{Schedulehelper::FREQ_INTERVALS_DAILY[item.freq_interval-1][1]}" + "<br/>"
            display << "Starting: #{(item.start_dt_tm).to_date.to_s(:long)}<br/>"
            display << "Ending: #{(item.end_dt_tm).to_date.to_s(:long)} <br/>"
         elsif item.freq_type == 7 
            display << "#{Schedulehelper::FREQ_INTERVALS_WEEKLY[item.freq_interval-1][1]}  <br/>"
            display << "Starting: #{(item.start_dt_tm).to_date.to_s(:long)} <br/>"
            display << "Ending: #{(item.end_dt_tm).to_date.to_s(:long)} <br/>"
            vals = Schedulehelper.ExtractFreqIntQualIntoArr(item.freq_interval_qual,false)
            display << "on "
            vals.reverse.each{|val |
            display << "#{Schedulehelper::FREQ_INTERVALS_QUAL_WEEKLY[val][1]}"
            if vals.index(val).to_i != 0 
                display <<   ","
            end 
            }
        elsif item.freq_type == 8 
            display << "#{Schedulehelper::FREQ_INTERVALS_MONTHLY[item.freq_interval-1][1]}  <br/>"
            display << "Starting:  #{(item.start_dt_tm).to_date.to_s(:long)} <br/>"
            display << "Ending:  #{(item.end_dt_tm).to_date.to_s(:long)}<br/>"
            vals = Schedulehelper.ExtractFreqIntQualIntoArr(item.freq_interval_qual,false)
            display << "on "
            vals.each{|val |
            display << "#{Schedulehelper::FREQ_INTERVALS_QUAL_DATE[val][1] }"
            if vals.index(val).to_i != 0 
                display <<   ","
            end
            } 
       elsif item.freq_type == 9 
            display << "#{ Schedulehelper::FREQ_INTERVALS_MONTHLY[item.freq_interval-1][1]}  <br/>"
            display << "Starting: #{ tz(item.start_dt_tm).to_date.to_s(:long)}<br/>"
            display << "Ending: #{ tz(item.end_dt_tm).to_date.to_s(:long)}<br/>"
            vals = Schedulehelper.ExtractFreqIntQualIntoArr(item.freq_interval_qual,false)
            display << "on "
            vals.each{|val |
            display << "#{Schedulehelper::FREQ_INTERVALS_QUAL_DAY[val][1] }"
            if vals.index(val).to_i != 0 
                display <<   ","
            end
            } 
       
        end 
        return display
  end
end
