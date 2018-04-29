class Api::UsersController < ApplicationController
  def find_user
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    render 'api/users/show'
  end

  def create_user
    firebase_uid, error = decode_token(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    # Checks if phone number already has an account created by another user's SMS
    if params[:phone_number]
      @client = User.find_by_phone_number(params[:phone_number])
    elsif params[:email]
      @client = User.find_by_email(params[:email])
    else
      render json: ['No phone number or email given'], status: 404 and return
    end

    if @client
      if @client.update({ firebase_uid: firebase_uid })
        render 'api/users/show' and return
      else
        render json: @client.errors.full_messages, status: 422 and return
      end
    else
      @client = User.new({ phone_number: params[:phone_number], firebase_uid: firebase_uid, email: params[:email] })

      if @client.save
        render 'api/users/show' and return
      else
        render json: @client.errors.full_messages, status: 422 and return
      end
    end
  end

  def edit_user
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if @client.update(user_params)
      render 'api/users/show'
    else
      render json: @client.errors.full_messages, status: 422
    end
  end

  private

  def user_params
    params.permit(:phone_number, :email, :username, :avatar_url)
  end
end
