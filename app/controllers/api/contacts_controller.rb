class Api::ContactsController < ApplicationController
  def get_contacts_with_accounts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @users = User.where('phone_number IN (?) and firebase_uid IS NULL', params[:phone_numbers])

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

    user, error = find_or_create_contact_user(client.id, params[:phone_number])

    if error
      render json: [error], status: 422 and return
    end

    # TODO: add Twilio code
    render json: [] and return
  end

end
