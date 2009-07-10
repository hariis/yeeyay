class EventReview < ActiveRecord::Base
  belongs_to :event
  belongs_to :user, :foreign_key => :added_by
  
  validates_presence_of :title, :message => ' - Please provide a title'
  validates_presence_of :details, :message => ' - Please share your experience'
  
  def created_by?(a_user)
    self.user.id == a_user.id
  end
end
