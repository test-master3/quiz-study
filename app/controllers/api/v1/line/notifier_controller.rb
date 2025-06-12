module Api
  module V1
    module Line
      class NotifierController < ApplicationController
        protect_from_forgery with: :null_session
        before_action :check_api_key

        def quiz_today
          # LINE連携しており、クイズを1つ以上持っているユーザーを取得
          # より確実な`joins`と`distinct`を使う方法に変更します
          users_with_quizzes = User.joins(:quizzes)
                                     .where.not(users: { line_uid: nil })
                                     .distinct
                                     .includes(:quizzes)

          # APIのレスポンス形式（GASが期待する形）に整形します
          results = users_with_quizzes.map do |user|
            {
              line_uid: user.line_uid,
              # ユーザーが持つ全てのクイズ情報を整形して配列にします
              quizzes: user.quizzes.map do |quiz|
                {
                  quiz_text: quiz.quiz_text,
                  quiz_choices: quiz.quiz_choices,
                  quiz_link: quiz.quiz_link
                }
              end
            }
          end

          render json: { users: results }
        end

        private

        def check_api_key
          expected_key = ENV['QUIZ_API_KEY']
          provided_key = request.headers['X-API-KEY']

          unless provided_key == expected_key
            render json: { error: "Unauthorized" }, status: :unauthorized
          end
        end
      end
    end
  end
end