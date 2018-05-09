class Api::ContactsController < ApplicationController
  def get_contacts_with_accounts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @users = User.where('phone_number IN (?) and firebase_uid IS NULL', params[:phone_numbers])
    @users.sort_by do |user|
      user.created_at
    end
    @users.reverse

    render 'api/users/index'
  end

  def get_other_contacts
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    render json: params[:phone_numbers] - User.where('phone_number IN (?)', params[:phone_numbers]).pluck(:phone_number)
  end

  def invite_contact
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    unless params[:phone_number]
      render json: ['No phone number given'], status: 404 and return
    end

    contact_user, contact_error = find_or_create_contact_user(client.id, params[:phone_number])

    if contact_error
      render json: [contact_error], status: 422 and return
    end

    send_twilio_sms(params[:phone_number], get_sms_start_string(client) + " invited you to join Postcard!\n\n-- Download Now --\nhttps://postcard.insiya.io/?utm_source=app&utm_term=invite")

    render json: {} and return
  end

end
