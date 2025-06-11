class AdminController < ApplicationController
  def new
  end

  def create
    user = User.find(params[:user_id])
    user.update!(line_uid: params[:line_uid])

    redirect_to new_admin_path, notice: "line_uid 登録しました！"
  end
end