class ApplicationController < ActionController::Base
  before_action :basic_auth, if: -> { Rails.env.production? }, unless: :api_or_webhook_controller?
  before_action :set_recent_questions, if: :user_signed_in?

  def after_sign_up_path_for(resource)
    new_question_path
  end

  private

  def set_recent_questions
    @questions = current_user.questions.order(created_at: :desc).limit(5)
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      # 環境変数から認証情報を取得
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end

  # APIまたはLINEのWebhookからのリクエストかを判定するメソッド
  def api_or_webhook_controller?
    self.class.name.start_with?('Api::') || self.class == LineBotWebhookController
  end
end
