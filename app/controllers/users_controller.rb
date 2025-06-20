class UsersController < ApplicationController
  # app/controllers/users_controller.rb
  def show
    @user = User.find(params[:id])
    @quizzes = @user.quizzes.order(created_at: :desc).limit(5)
  end
end
