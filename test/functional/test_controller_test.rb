require 'test_helper'

class TestControllerTest < ActionController::TestCase
  test "should get pass" do
    get :pass
    assert_response :success
  end

  test "should get fail" do
    get :fail
    assert_response :success
  end

end
