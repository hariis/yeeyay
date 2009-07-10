require 'test_helper'

class VenueReviewsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:venue_reviews)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create venue_review" do
    assert_difference('VenueReview.count') do
      post :create, :venue_review => { }
    end

    assert_redirected_to venue_review_path(assigns(:venue_review))
  end

  test "should show venue_review" do
    get :show, :id => venue_reviews(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => venue_reviews(:one).id
    assert_response :success
  end

  test "should update venue_review" do
    put :update, :id => venue_reviews(:one).id, :venue_review => { }
    assert_redirected_to venue_review_path(assigns(:venue_review))
  end

  test "should destroy venue_review" do
    assert_difference('VenueReview.count', -1) do
      delete :destroy, :id => venue_reviews(:one).id
    end

    assert_redirected_to venue_reviews_path
  end
end
