class FollowingsController < ApplicationController
  before_action :authorize_request
  before_action :set_following, only: [:show]
  before_action :set_user
 
  # GET /followings/1
  def show
    render json: {following: @following.length()}, status: :ok
  end

  # POST /followings
  def create
    begin
    @friend = User.find_by(username: params[:username])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    end
    @following = @current_user.followings.build(:friend_id => @friend.id)

    if @following.save
      render json: {message: 'User Followed'}, status: :ok, location: @following
    else
      render json: @following.errors, status: :unprocessable_entity
    end
  end

  # DELETE /followings/1
  def destroy
    begin
      @friend = User.find_by(username: params[:username])
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      end
    @following = @current_user.followings.find(@friend.id)
    @following.destroy
    render json: {message: 'User Unfollowed'}, status: :ok
  end

  def followers
    @followers = @current_user.followers.all
    render json: {followers: @followers.length()}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_following
      @following = Following.where(user_id: @current_user.id)
    end

    def set_user      
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      @user = JsonWebToken.decode({token: header})
      @current_user = User.find(@user[:user_id])
    end

end
