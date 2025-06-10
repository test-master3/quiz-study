class ApplicationController < ActionController::Base
  before_action :basic_auth, if: -> { Rails.env.production? }

  def after_sign_up_path_for(resource)
    new_question_path
  end

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      # 環境変数から認証情報を取得
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
