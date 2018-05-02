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

    if params[:user_ids].size + params[:contact_phone_numbers].size < 2
      render json: ['Minimum 2 recipients required'], status: 403 and return
    end

    @group = Group.new({ owner_id: @client.id })

    if @group.save
      # Create groupling for client
      create_groupling(@group.id, @client.id)

      # Create grouplings for other users
      params[:user_ids].each do |user_id|
        create_groupling(@group.id, user_id)
        next
      end

      params[:contact_phone_numbers].each do |phone_number|
        contact_user, contact_error = find_or_create_contact_user(@client.id, phone_number)

        if contact_user
          create_groupling(@group.id, contact_user.id)
          send_twilio_sms(phone_number, "User \"" +  @client.username + "\" added you to a group on Postcard!\n\nDownload now: http://www.insiya.io/")
          next
        else
          render json: [contact_error], status: 422 and return
        end
      end

      # Send pusher update to all members
      send_pusher_group_to_grouplings(@group, [@client.id], 'receive-group', @client)

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
      create_groupling(@group.id, user_id)
      next
    end

    params[:contact_phone_numbers].each do |phone_number|
      contact_user, contact_error = find_or_create_contact_user(@client.id, phone_number)

      if contact_user
        create_groupling(@group.id, contact_user.id)
      else
        render json: [contact_error], status: 422 and return
      end
    end

    # Send pusher update to all members
    pusher_group = @group.as_json
    @group.groupling_users.where('user_id != ? and firebase_uid IS NOT NULL', @client.id).each do |user|
      pusher_group[:users] = @group.groupling_users.where('user_id != ?', user.id).as_json

      if params[:user_ids].include?(user.id)
        create_notification(@client.id, user.id, nil, @client.username + ' added you to a group.', { type: 'receive-group' })
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

    groupling = Groupling.find_by_group_id_and_user_id(params[:id], params[:user_id])

    unless groupling
      render json: ['User not found'], status: 404 and return
    end

    if groupling.destroy
      # If person leaving is the owner...
      if @group[:owner_id] == params[:user_id].to_i
        # If there's no one left in the group, destroy it
        if @group.groupling_users.size == 0
          unless @group.destroy
            render json: @group.errors.full_messages, status: 422
          end
        # If the client is leaving, change the owner
        else
          unless Group.update(@group.id, :owner_id => @group.groupling_users[0].id)
            render json: @group.errors.full_messages, status: 422
          end
        end
      end

      # Update removed user using Pusher
      Pusher.trigger('private-' + params[:user_id].to_s, 'remove-group', { group_id: @group.id })

      # Send pusher update to all other members
      send_pusher_group_to_grouplings(@group, [@client.id, params[:user_id]], 'edit-group', @client)

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
      send_pusher_group_to_grouplings(@group, [@client.id], 'edit-group', @client)

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
    @group.groupling_users.where('user_id != ? and firebase_uid IS NOT NULL', @client.id).each do |groupling|
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
