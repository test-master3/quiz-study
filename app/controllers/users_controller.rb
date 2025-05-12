class UsersController < ApplicationController
  # app/controllers/users_controller.rb
  def show
    @user = User.find(params[:id])
  end
end
