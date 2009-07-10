class EventReviewsController < ApplicationController
  before_filter :require_user, :except => [:show]
  before_filter :load_event
  layout "events"
  def load_event
     @event = Event.find(params[:event_id])
  end
  # GET /event_reviews
  # GET /event_reviews.xml
  def index
    @event_reviews = EventReview.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event_reviews }
    end
  end

  # GET /event_reviews/1
  # GET /event_reviews/1.xml
  def show
    @event_review = EventReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event_review }
    end
  end

  # GET /event_reviews/new
  # GET /event_reviews/new.xml
  def new
    @event_review = @event.event_reviews.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event_review }
    end
  end

  # GET /event_reviews/1/edit
  def edit
    @event_review = EventReview.find(params[:id])
  end

  # POST /event_reviews
  # POST /event_reviews.xml
  def create
    @event_review = @event.event_reviews.new(params[:event_review])
    @event_review.added_by = current_user.id
    respond_to do |format|
      if @event.event_reviews << @event_review
        flash[:notice] = 'Thank you for your valuable review.'
        format.html { redirect_to(event_path(@event)) }
        format.xml  { render :xml => @event_review, :status => :created, :location => @event_review }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_review.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /event_reviews/1
  # PUT /event_reviews/1.xml
  def update
    @event_review = EventReview.find(params[:id])
    @owner = @event_review.created_by?(current_user)
    respond_to do |format|
      if @owner && @event_review..update_attributes(params[:event_review])
        flash[:notice] = 'Thank you for updating your valuable review.'
        format.html { redirect_to(event_path(@event)) }
        format.xml  { head :ok }
      else
        format.html { 
          if !@owner
            flash[:notice] = "Only the member that added this review can edit. <br/> If you feel the information is incorrect, please contact us."    
            redirect_to(event_path(@event))
          else
            render :action => "edit" 
          end
        }
        format.xml  { render :xml => @event_review.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  # DELETE /event_reviews/1
  # DELETE /event_reviews/1.xml
  def destroy
    @event_review = EventReview.find(params[:id])
    @event_review.destroy

    respond_to do |format|
      format.html { redirect_to(event_reviews_url) }
      format.xml  { head :ok }
    end
  end
end
