class Api::GroupsController < ApplicationController

  def create_group
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if params[:user_ids].size < 2
      render json: ['Minimum 2 user_ids required'], status: 403 and return
    end

    @group = Group.new({ owner_id: @client.id })

    if @group.save
      params[:user_ids].each do |user_id|
        # Create groupling for each user
        groupling = Groupling.new({ group_id: @group.id, user_id: user_id })

        if groupling.save
          next
        else
          render json: ['Creating group failed.'], status: 422 and return
        end
      end

      render 'api/groups/show'
    else
      render json: @group.errors.full_messages, status: 422
    end
  end

end
