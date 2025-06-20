# app/controllers/quizzes_controller.rb
class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @quizzes = current_user.quizzes.includes(:question).order(created_at: :desc)
  end

  def show
    @quiz = current_user.quizzes.find(params[:id])
  end

  def manage
    case params[:commit]
    when 'delete'
      # --- 削除ボタンが押された時の処理 ---
      if params[:delete_quiz_ids].blank?
        return redirect_to quizzes_path, alert: "削除するクイズが選択されていません。"
      end
      
      quizzes_to_delete = current_user.quizzes.where(id: params[:delete_quiz_ids])
      count = quizzes_to_delete.count
      
      if quizzes_to_delete.destroy_all
        redirect_to quizzes_path, notice: "#{count}件のクイズを削除しました。"
      else
        redirect_to quizzes_path, alert: "クイズの削除に失敗しました。"
      end
    else
      # --- 更新ボタンが押された時の処理 (デフォルト) ---
      update_send_to_line
    end
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

  def bulk_delete
    if params[:quiz_ids].blank?
      return redirect_to quizzes_path, alert: "削除するクイズが選択されていません。"
    end
    
    quizzes_to_delete = current_user.quizzes.where(id: params[:quiz_ids])
    count = quizzes_to_delete.count
    
    if quizzes_to_delete.destroy_all
      redirect_to quizzes_path, notice: "#{count}件のクイズを削除しました。"
    else
      redirect_to quizzes_path, alert: "クイズの削除に失敗しました。"
    end
  end
end