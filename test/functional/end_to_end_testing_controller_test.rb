# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class EndToEndTestingControllerTest < ActionController::TestCase
  def test_truth
    get :index
    assert_response :success
  end
end
