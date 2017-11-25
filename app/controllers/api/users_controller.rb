class Api::UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    if @user.save
      render 'api/users/show'
    else
      render json: @user.errors.full_messages, status: 422
    end
  end

  private

  def user_params
    params.permit(:phone_number, :session_token)
  end
end
