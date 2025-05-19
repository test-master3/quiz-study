require "test_helper"

class GeminiControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get gemini_index_url
    assert_response :success
  end
end
