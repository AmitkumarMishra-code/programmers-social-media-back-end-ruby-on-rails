class UsersController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :find_friend, only: [:friendprofile]
  before_action :set_user, only: [:selfprofile, :friendprofile]

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def selfprofile
    render json: @profile, status: :ok
  end

  def friendprofile
    render json: @profile, status: :ok
  end

  private

  def find_friend
    @friend = User.find_by_id(params[:id])
    details(@friend)
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'User not found' }, status: :not_found
  end

  def user_params
    params.permit(
      :photoURL, :name, :username, :email, :password
    )
  end

  def details(user)
    @followers = user.followers.all
    @following = Following.where(user_id: user)
    @posts = Post.where(author: user).order(created_at: :desc).limit(10)
    @likes = Like.where(user_id_id: user, post_id_id: @posts)
    @currentlyFollowing = false
    @isSelf = true

    if params[:id]
      mappedFriends = @followers.map {|friends| friends.friend_id}
      puts(mappedFriends)
      if mappedFriends.include?(@current_user.id)
        @currentlyFollowing = true
      end
      @isSelf = false
    end

    @profile = { 
      username: user.username,
      following: @following.length,
      followers: @followers.length,
      photoURL: user.photoURL,
      name: user.name,
      posts: @posts,
      likesMap: @likes,
      self: @isSelf,
      currentlyFollowing: @currentlyFollowing
    }
  end
  
  def set_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    @user = JsonWebToken.decode({token: header})
    @current_user = User.find(@user[:user_id])
    details(@current_user)
  end
end