class LineAccountsController < ApplicationController
  def new
  end

  def create
    # ここは仮：Bot追加を促す画面などを表示
    redirect_to root_path, notice: "LINE連携用のBotを追加してください"
  end
end
