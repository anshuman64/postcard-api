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
      render json: ['Minimum 2 recipients required'], status: 403 and return
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

      # Send pusher update to all members
      pusher_group = @group.attributes
      @group.groupling_users.where('user_id != ?', @client.id).each do |user|
        pusher_group[:users] = @group.groupling_users.where('user_id != ?', user.id).as_json
        create_notification(@client, user.id, nil, @client.username + ' added you to a group.', { type: 'receive-group' })
        Pusher.trigger('private-' + user.id.to_s, 'receive-group', { group: pusher_group })
      end

      render 'api/groups/show'
    else
      render json: @group.errors.full_messages, status: 422
    end
  end

  def create_grouplings
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @group = Group.find(params[:group_id])

    params[:user_ids].each do |user_id|
      # Create groupling for each user
      groupling = Groupling.new({ group_id: @group.id, user_id: user_id })

      if groupling.save
        next
      else
        render json: ['Creating group failed.'], status: 422 and return
      end
    end

    # Send pusher update to all members
    pusher_group = @group.attributes
    @group.groupling_users.where('user_id != ?', @client.id).each do |user|
      pusher_group[:users] = @group.groupling_users.where('user_id != ?', user.id).as_json
      if params[:user_ids].include?(user.id)
        create_notification(@client, user.id, nil, @client.username + ' added you to a group.', { type: 'receive-group' })
        Pusher.trigger('private-' + user.id.to_s, 'receive-group', { group: pusher_group })
      else
        Pusher.trigger('private-' + user.id.to_s, 'edit-group', { group: pusher_group })
      end
    end

    render 'api/groups/show'
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

    user_id = params[:user_id]
    groupling = Groupling.find_by_group_id_and_user_id(params[:id], user_id)

    unless groupling
      render json: ['User not found'], status: 404 and return
    end

    if groupling.destroy
      if @group[:owner_id] == user_id.to_i
        # If there's no one left in the group, destroy it
        if @group.groupling_users.size == 0
          unless @group.destroy
            render json: @group.errors.full_messages, status: 422
          end
        # If the client is leaving, change the owner
        else
          next_owner = @group.groupling_users[0]
          if Group.update(@group.id, :owner_id => next_owner.id)
            pusher_group = @group.attributes
            pusher_group[:users] = @group.groupling_users.where('user_id != ?', next_owner.id).as_json
            Pusher.trigger('private-' + next_owner.id.to_s, 'edit-group', { group: pusher_group })
          else
            render json: @group.errors.full_messages, status: 422
          end
        end
      end

      # Update removed user using Pusher
      Pusher.trigger('private-' + user_id.to_s, 'remove-group', { group_id: @group.id })

      # Send pusher update to all other members
      pusher_group = @group.attributes
      @group.groupling_users.where('user_id != ? and user_id != ?', @client.id, user_id).each do |user|
        pusher_group[:users] = @group.groupling_users.where('user_id != ?', user.id).as_json
        Pusher.trigger('private-' + user.id.to_s, 'edit-group', { group: pusher_group })
      end

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
      # Send pusher update to all other members
      pusher_group = @group.attributes
      @group.groupling_users.where('user_id != ?', @client.id).each do |user|
        pusher_group[:users] = @group.groupling_users.where('user_id != ?', user.id).as_json
        Pusher.trigger('private-' + user.id.to_s, 'edit-group', { group: pusher_group })
      end

      render 'api/groups/show'
    else
      render json: @group.errors.full_messages, status: 422
    end
  end

  def destroy_group
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @group = Group.find(params[:id])

    unless @group
      render json: ['Post not found'], status: 404 and return
    end

    unless @group[:owner_id] == @client.id
      render json: ['Unauthorized request'], status: 403 and return
    end

    # Update all members using Pusher
    @group.grouplings.where('user_id != ?', @client.id).each do |groupling|
      Pusher.trigger('private-' + groupling.user_id.to_s, 'remove-group', { group_id: @group.id })
    end

    if @group.destroy
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
