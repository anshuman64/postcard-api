class Api::GroupsController < ApplicationController
  def get_groups
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @groups = @client.groups

    render 'api/groups/index'
  end

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
      # Create groupling for client
      client_groupling = Groupling.new({ group_id: @group.id, user_id: @client.id })

      unless client_groupling.save
        render json: ['Creating group failed.'], status: 422 and return
      end

      # Create grouplings for other users
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

  def destroy_groupling
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @group = Group.find(params[:id])

    unless @group
      render json: ['Group not found'], status: 404 and return
    end

    groupling = Groupling.find_by_group_id_and_user_id(params[:id], params[:user_id])

    unless groupling
      render json: ['User not found'], status: 404 and return
    end

    if groupling.destroy
      render 'api/groups/show'
    else
      render json: @group.errors.full_messages, status: 422
    end
  end

  def edit_group
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @group = Group.find(params[:group_id])

    if @group.update(group_params)
      render 'api/groups/show'
    else
      render json: @group.errors.full_messages, status: 422
    end
  end

  private

  def group_params
    params.permit(:name)
  end

end