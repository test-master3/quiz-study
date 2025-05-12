require "test_helper"

class AnswersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get answers_create_url
    assert_response :success
  end

  test "should get index" do
    get answers_index_url
    assert_response :success
  end
end
