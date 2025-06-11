class LineAccountsController < ApplicationController
  before_action :authenticate_user!

  def new
    # LINE連携の案内ページ（QRコードなど）
  end

  def create
    if session[:line_uid].present?
      current_user.update(line_uid: session[:line_uid], line_linked: true)
      session.delete(:line_uid)
      redirect_to root_path, notice: 'LINE連携が完了しました🎉'
    else
      redirect_to root_path, alert: 'LINE連携に失敗しました'
    end
  end
end