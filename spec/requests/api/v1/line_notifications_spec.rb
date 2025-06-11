require 'rails_helper'

RSpec.describe "Api::V1::LineNotifications", type: :request do
  describe "GET /quiz_today" do
    it "returns http success" do
      get "/api/v1/line_notifications/quiz_today"
      expect(response).to have_http_status(:success)
    end
  end

end
