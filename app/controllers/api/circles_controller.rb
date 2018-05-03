class Api::CirclesController < ApplicationController
  def get_circles
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @circles = @client.circles

    render 'api/circles/index'
  end

  def create_circle
    @client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    if params[:user_ids].size + params[:group_ids].size < 2
      render json: ['Minimum 2 recipients required'], status: 403 and return
    end

    @circle = Circle.new({ creator_id: @client.id, name: params[:name] })
    if @circle.save
      # Create circlings for users
      params[:user_ids].each do |user_id|
        circling = Circling.new({ circle_id: @circle.id, user_id: user_id })

        unless circling.save
          render json: circling.errors.full_messages, status: 422 and return
        end

        next
      end

      # Create circlings for groups
      params[:group_ids].each do |group_id|
        circling = Circling.new({ circle_id: @circle.id, group_id: group_id })

        unless circling.save
          render json: circling.errors.full_messages, status: 422 and return
        end

        next
      end

      render 'api/circles/show'
    else
      render json: @circle.errors.full_messages, status: 422
    end
  end

  def destroy_circle
    client, error = decode_token_and_find_user(request.headers['Authorization'])

    if error
      render json: [error], status: 401 and return
    end

    @circle = Circle.find(params[:id])

    unless @circle
      render json: ['Circle not found'], status: 404 and return
    end

    if @circle.destroy
      render 'api/circles/show'
    else
      render json: @circle.errors.full_messages, status: 422
    end
  end

end
