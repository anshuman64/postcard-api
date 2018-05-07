class Api::UsersController < ApplicationController
  def find_user
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if @client.touch(:last_login)
      render 'api/users/show'
    else
      render json: @client.errors.full_messages, status: 422 and return
    end
  end

  def create_user
    firebase_uid, error = decode_token(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if params[:phone_number]
      @client = User.find_by_phone_number(params[:phone_number])
    elsif params[:email]
      @client = User.find_by_email(params[:email])
    else
      render json: ['No phone number or email given'], status: 404 and return
    end

    # Checks if phone number already has an account created by another user's SMS
    if @client
      if @client.update({ firebase_uid: firebase_uid, last_login: Time.now })
        render 'api/users/show' and return
      else
        render json: @client.errors.full_messages, status: 422 and return
      end
    else
      @client = User.new({ phone_number: params[:phone_number], firebase_uid: firebase_uid, email: params[:email], last_login: Time.now })

      if @client.save
        # Debug Test: uncomment for production
        share = Share.new({ post_id: 151, recipient_id: @client.id }) # 151 is a hard-coded number for 'Welcome to Postcard!' post from contact@insiya.io account

        unless share.save
          render json: share.errors.full_messages, status: 422 and return
        end

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

  def edit_avatar
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if params[:medium]
      medium = Medium.new({ aws_path: params[:medium][:awsPath], mime_type: params[:medium][:mime], height: params[:medium][:height], width: params[:medium][:width], owner_id: @client.id })

      unless medium.save
        render json: medium.errors.full_messages, status: 422 and return
      end

      avatar_medium_id = medium.id
    end

    if @client.update({ avatar_medium_id: avatar_medium_id })
      render 'api/users/show'
    else
      render json: @client.errors.full_messages, status: 422
    end
  end

  private

  def user_params
    params.permit(:phone_number, :email, :username, :full_name)
  end
end
