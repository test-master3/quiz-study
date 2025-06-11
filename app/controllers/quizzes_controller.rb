# app/controllers/quizzes_controller.rb
class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes.includes(:question).order(created_at: :desc)
  end

  def update_send_to_line
    # 一旦全部OFFにする
    current_user.quizzes.update_all(send_to_line: false)

    # チェック入れたIDだけONにする
    if params[:quiz_ids].present?
      current_user.quizzes.where(id: params[:quiz_ids]).update_all(send_to_line: true)
    end

    redirect_to quizzes_path, notice: "送信対象を更新しました！"
  end

  def reset_send_to_line
    current_user.quizzes.update_all(send_to_line: false)
    redirect_to quizzes_path, notice: "全てのクイズを送信対象から外しました。"
  end
end