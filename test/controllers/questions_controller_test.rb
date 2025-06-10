require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)  # fixtureからユーザーを取得
  end

  test "should redirect to login when not authenticated" do
    get questions_path
    assert_redirected_to new_user_session_path
  end

  test "should get index when authenticated" do
    sign_in @user
    get questions_path
    assert_response :success
  end

  test "should get new when authenticated" do
    sign_in @user
    get new_question_path
    assert_response :success
  end

  test "should create question when authenticated" do
    sign_in @user
    assert_difference('Question.count') do
      post questions_path, params: { question: { content: "Test question" } }
    end
    assert_redirected_to new_question_path
  end
end
