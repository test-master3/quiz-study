require "test_helper"

class LineAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get line_accounts_new_url
    assert_response :success
  end

  test "should get create" do
    get line_accounts_create_url
    assert_response :success
  end
end
