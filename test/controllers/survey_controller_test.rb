require 'test_helper'

class SurveyControllerTest < ActionController::TestCase
  test "should get get_personal_data" do
    get :get_personal_data
    assert_response :success
  end

  test "should get get_self_esteem" do
    get :get_self_esteem
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
