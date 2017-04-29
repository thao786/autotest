require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get billing" do
    get dashboard_billing_url
    assert_response :success
  end

  test "should get preferences" do
    get dashboard_preferences_url
    assert_response :success
  end

  test "should get index" do
    get dashboard_index_url
    assert_response :success
  end

end
