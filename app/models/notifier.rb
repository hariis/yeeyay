class Notifier < ActionMailer::Base
    default_url_options[:host] = "www.plannerbee.com"

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          "YeeYaY Notifier <noreply@plannerbee.com>"
    recipients    user.email
    sent_on       Time.zone.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def deliver_notify_subscriber(user, queries)
    subject       "YeeYay | New Venue(s) added"
    from          "YeeYaY Notifier <noreply@yeeyay.com>"
    recipients    user.email
    sent_on       Time.zone.now
    body             :user => user, :queries => queries
  end
  
  def share_venue(venue,sent_by)
    setup_email(venue)
    @subject    += "#{sent_by.login} is sharing with you"
  
    @body[:name]  = venue.name
    @body[:url] = venue.url
    @body[:yeeyay_url] = "http://www.yeeyay.com/venues/" + venue.id 
    @body[:mycomments]  = venue.comments
    @body[:sender] = "#{sent_by.login}"
  end
  def share_event(event,sent_by)
    setup_email(event)
    @subject    += "#{sent_by.login} is sharing with you"
  
    @body[:name]  = event.title
    @body[:venue_name] = event.venue.name
    @body[:yeeyay_url] = "http://www.yeeyay.com/events/" + event.id 
    @body[:mycomments]  = event.comments
    @body[:event] = event
    @body[:sender] = "#{sent_by.login}"
  end
  
  protected
    def setup_email(venue)
      @recipients  = "#{venue.emails}"
      @from        = "YeeYaY <yeeyay-notifier@plannerbee.com>"
      headers         "Reply-to" => "yeeyay-notifier@plannerbee.com"
      @subject     = "[YeeYaY] "
      @sent_on     = Time.zone.now
      @content_type = "text/html"
    end
end
