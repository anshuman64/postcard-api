class Api::ContactsController < ApplicationController
  def get_other_contacts
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

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
end
