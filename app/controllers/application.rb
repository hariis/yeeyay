# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '3d164c836aab530ebb566317c69ab3d6'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user
  
    def displaydate       
             if  params[:freqtype] == '1' 
                 @freqintervals = nil
             elsif  params[:freqtype]   == '6' then
                  @freqintervals = Schedulehelper::FREQ_INTERVALS_DAILY
            elsif params[:freqtype]   == '7' then
                  @freqintervals = Schedulehelper::FREQ_INTERVALS_WEEKLY
                  @freqintervalsqual= Schedulehelper::FREQ_INTERVALS_QUAL_WEEKLY
            elsif params[:freqtype]   == '8' then
                  @freqintervals = Schedulehelper::FREQ_INTERVALS_MONTHLY
                  @freqintervalsqual= Schedulehelper::FREQ_INTERVALS_QUAL_DATE
            elsif params[:freqtype]   == '9' then
                  @freqintervals = Schedulehelper::FREQ_INTERVALS_MONTHLY
                  @freqintervalsqual= Schedulehelper::FREQ_INTERVALS_QUAL_DAY
            end
            @start = Time.now
            @end = Time.now + 1.month
            @freq_interval_selected = '1'
            @freqintervalsqual_selected = '1'
            render :partial => "displaydate"
         
  end        
  
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    #validating email
    def validate_emails(emails)		
            #Parse the string into an array
              valid_emails =[]
              valid_emails = string_to_array(emails)             

              offending_email = ""
              addresses = []
              valid_emails.each {|email|
                      if validate_simple_email(email)
                             addresses << email
                              next
                      elsif  validate_ab_style_email(email)
                                addresses << email
                                next
                      else
                          offending_email = email
                              break
                      end			
              }

              if offending_email == ""
                      return true
              else
                  @invalid_emails_message = "Email address: #{offending_email} incorrect.	Please try again."
                      return false
              end
         end   
   def validate_simple_email(email)
        emailRE= /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/
        return email =~ emailRE
   end         
   def validate_ab_style_email(email)
        email.gsub!(/\A"/, '\1')	 
         str = email.split(/ /)
         str.delete_if{|x| x== ""}
         email = str[str.size-1].delete "<>"
         emailRE= /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/
         return email =~ emailRE
   end
   def string_to_array(stringitem)
                #Parse the string into an array
              valid_array =[]
              return if stringitem == nil
              valid_array.concat(stringitem.split(/,/))

              # delete any blank emails
              valid_array = valid_array.delete_if { |t| t.empty? }

              # trim spaces around all tags
              valid_array = valid_array.map! { |t| t.strip }

              # downcase all tags
              valid_array = valid_array.map! { |t| t.downcase }

              # remove duplicates
              valid_array = valid_array.uniq
    end
   def is_admin
    current_user.has_role?('admin')
  end
end
