class FollowingsController < ApplicationController
  before_action :authorize_request
  before_action :set_following, only: [:show]
  before_action :set_current_user, only: [:create, :destroy]
  before_action :set_user, only: [:followers]
 
  # GET /followings/1
  def show
    render json: {following: @following.length()}, status: :ok
  end

  # POST /followings
  def create
    puts(@current_user)
    @friend = User.find(params[:friend_id])
    puts(@friend)
    @following = @current_user.followings.build(:friend_id => params[:friend_id])
    puts("after following")
    puts(@following)

    if @following.save
      render json: @following, status: :created, location: @following
    else
      render json: @following.errors, status: :unprocessable_entity
    end
  end

  # DELETE /followings/1
  def destroy
    @following = @current_user.followings.find(params[:id])
    @following.destroy
  end

  def followers
    @followers = @user.followers.all
    render json: {followers: @followers.length()}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_following
      @following = Following.where(user_id: params[:id])
    end

    def set_current_user
      @current_user = User.find(params[:user_id])
    end

    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def following_params
      params.require(:following).permit(:user_id, :friend_id)
    end
end
