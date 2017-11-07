class Api::SessionsController < ApplicationController

  def auth
    debugger
    phone_number = params[:user][:phone_number]
    @user = User.find_by_credentials(phone_number)

    if @user
      render json: ['User exists'], status: 200
    else
      @user = User.new({ phone_number: phone_number })

      if @user.save
        render json: ['New user created'], status: 200
      else
        render json: @user.errors.full_messages, status: 422
      end
    end
  end

  def validate
    debugger
  end

end
