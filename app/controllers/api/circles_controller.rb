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

    if params[:user_ids].size < 2
      render json: ['Minimum 2 user_ids required'], status: 403 and return
    end

    @circle = Circle.new({ creator_id: @client.id, name: params[:name] })

    if @circle.save
      params[:user_ids].each do |user_id|
        # Create circling for each user
        circling = Circling.new({ circle_id: @circle.id, user_id: user_id })

        if circling.save
          next
        else
          render json: ['Creating circle failed.'], status: 422 and return
        end
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
