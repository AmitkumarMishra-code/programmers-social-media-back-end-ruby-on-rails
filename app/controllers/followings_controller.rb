class FollowingsController < ApplicationController
  before_action :authorize_request
  before_action :set_following, only: [:destroy, :create]
  before_action :set_user
 
  # POST /followings
  def create
    begin

    @friend = User.find_by(username: params[:username])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    end

    if(@following)
      render json: {errors: {message: 'Already following user!'}}, status: :unprocessable_entity
    else
      @newfollowing = @current_user.followings.build(:friend_id => @friend.id)

      if @newfollowing.save
        render json: {message: 'User Followed'}, status: :ok, location: @newfollowing
      else
        render json: @newfollowing.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /followings/1
  def destroy
    if(@following)
      @following.destroy
      render json: {message: 'User Unfollowed'}, status: :ok
    else
      render json: { errors: {message:'You have to follow a user first to unfollow them!'} }, status: :unauthorized
    end
  end

  def followers
    @followers = @current_user.followers.all
    render json: {followers: @followers.length()}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_following
      @friend = User.find_by(username: params[:username])
      @following = Following.find_by(user_id: @current_user, friend_id: @friend)
    end

    def set_user      
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      @user = JsonWebToken.decode({token: header})
      @current_user = User.find(@user[:user_id])
    end

end
