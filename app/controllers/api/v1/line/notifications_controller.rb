module Api
  module V1
    module Line
      class NotificationsController < ApplicationController
        protect_from_forgery with: :null_session
        before_action :check_api_key

      def quiz_today
        quizzes = Quiz.where(send_to_line: true).includes(:user)

        results = quizzes.map do |quiz|
          {
            line_uid: quiz.user.line_uid,
            quiz_text: quiz.quiz_text,
            answer_text: quiz.question.answer_text,
            quiz_link: "https://quiz-study-ibeu.onrender.com/questions/#{quiz.question.id}"
          }
        end

        render json: { users: results }
      end

      private

      def check_api_key
        expected_key = ENV['QUIZ_API_KEY']  # ← 環境変数から読み込み（推奨）
        provided_key = request.headers['X-API-KEY']

        unless provided_key == expected_key
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end