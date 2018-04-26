class Api::ContactsController < ApplicationController
  def get_other_contacts
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    phone_numbers_with_accounts = []
    phone_numbers_without_accounts = []

    params[:phone_numbers].each do |phone_number|
      user = User.find_by_phone_number(phone_number)

      if !user
        phone_numbers_without_accounts += [phone_number]
      elsif !user[:firebase_uid]
        phone_numbers_with_accounts += [phone_number]
      end
    end

    render json: { phone_numbers_with_accounts: phone_numbers_with_accounts, phone_numbers_without_accounts: phone_numbers_without_accounts }
  end

  def invite_contact
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    def send_sms
      # TODO: add Twilio code
      render 'api/users/show' and return
    end

    def create_friendship(client, user)
      friendship = Friendship.new({ requester_id: client.id, requestee_id: user.id })

      if friendship.save
        send_sms
      else
        render json: friendship.errors.full_messages, status: 422 and return
      end
    end

    if error
      render json: [error], status: 401 and return
    end

    @user = User.find_by_phone_number(params[:phone_number])

    unless @user
      @user = User.new({ phone_number: params[:phone_number], email: params[:email] })

      if @user.save
        create_friendship(client, @user)
      else
        render json: @user.errors.full_messages, status: 422 and return
      end
    else
      friendship = Friendship.find_by_requester_id_and_requestee_id(client.id, @user.id)

      unless friendship
        create_friendship(client, @user)
      else
        send_sms
      end
    end
  end

end
