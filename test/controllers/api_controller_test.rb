require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get check" do
    get api_check_url
    assert_response :success
  end

end
