class LineAccountsController < ApplicationController
  before_action :authenticate_user!

  def new
    # 現在のユーザーの連携トークンを生成（または再生成）する
    current_user.generate_line_link_token
    @link_token = current_user.line_link_token
  end
end