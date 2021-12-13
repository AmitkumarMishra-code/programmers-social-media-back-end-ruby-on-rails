class FollowingsController < ApplicationController
  before_action :set_following, only: [:show, :update, :destroy]

  # GET /followings
  def index
    @followings = Following.all

    render json: @followings
  end

  # GET /followings/1
  def show
    render json: @following
  end

  # POST /followings
  def create
    @following = current_user.followings.build(:friend_id => params[:friend_id])

    if @following.save
      render json: @following, status: :created, location: @following
    else
      render json: @following.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /followings/1
  def update
    if @following.update(following_params)
      render json: @following
    else
      render json: @following.errors, status: :unprocessable_entity
    end
  end

  # DELETE /followings/1
  def destroy
    @following = current_user.followings.find(params[:id])
    @following.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_following
      @following = Following.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def following_params
      params.require(:following).permit(:user_id, :friend_id)
    end
end
