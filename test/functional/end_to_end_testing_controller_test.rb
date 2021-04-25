require File.expand_path('../../test_helper', __FILE__)

class EndToEndTestingControllerTest < ActionController::TestCase
  def test_truth
    get :index
    assert_response :success
  end
end
