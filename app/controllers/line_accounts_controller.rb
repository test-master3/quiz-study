class LineAccountsController < ApplicationController
  before_action :authenticate_user!

  def new
    @line_linked = current_user.line_linked?
    unless @line_linked
      # 未連携の場合のみ、連携トークンを生成する
      current_user.generate_line_link_token
      @link_token = current_user.line_link_token
    end
  end
end