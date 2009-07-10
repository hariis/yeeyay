class VenueReviewsController < ApplicationController
  before_filter :require_user, :except => [:show]
  before_filter :load_venue
  layout "venues"
  def load_venue
     @venue = Venue.find(params[:venue_id])
  end
  # GET /venue_reviews
  # GET /venue_reviews.xml
  def index
    @venue_reviews = VenueReview.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @venue_reviews }
    end
  end

  # GET /venue_reviews/1
  # GET /venue_reviews/1.xml
  def show
    @venue_review = VenueReview.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @venue_review }
    end
  end

  # GET /venue_reviews/new
  # GET /venue_reviews/new.xml
  def new
    @venue_review = @venue.venue_reviews.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @venue_review }
    end
  end

  # GET /venue_reviews/1/edit
  def edit
    @venue_review = VenueReview.find(params[:id])
  end

  # POST /venue_reviews
  # POST /venue_reviews.xml
  def create
    @venue_review = @venue.venue_reviews.new(params[:venue_review])
    @venue_review.added_by = current_user.id
    respond_to do |format|
      if @venue.venue_reviews << @venue_review
        flash[:notice] = 'Thank you for your valuable review.'
        format.html { redirect_to(venue_path(@venue)) }
        format.xml  { render :xml => @venue_review, :status => :created, :location => @venue_review }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @venue_review.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /venue_reviews/1
  # PUT /venue_reviews/1.xml
  def update
    @venue_review = VenueReview.find(params[:id])
    @owner = @venue_review.created_by?(current_user)
    respond_to do |format|
      if @owner && @venue_review.update_attributes(params[:venue_review])
        flash[:notice] = 'Thank you for updating your valuable review.'
        format.html { redirect_to(venue_path(@venue)) }
        format.xml  { head :ok }
      else
        format.html { 
          if !@owner
            flash[:notice] = "Only the member that added this review can edit. <br/> If you feel the information is incorrect, please contact us."    
            redirect_to(venue_path(@venue))
          else
            render :action => "edit" 
          end
        }
        format.xml  { render :xml => @venue_review.errors, :status => :unprocessable_entity }
      end
    end
  end
 private
  # DELETE /venue_reviews/1
  # DELETE /venue_reviews/1.xml
  def destroy
    @venue_review = VenueReview.find(params[:id])
    @venue_review.destroy

    respond_to do |format|
      format.html { redirect_to(venue_reviews_url) }
      format.xml  { head :ok }
    end
  end
end
