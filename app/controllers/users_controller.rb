class UsersController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :find_friend, only: [:friendprofile]
  before_action :self_details, only: :selfprofile
  before_action :set_user, only: [:selfprofile, :friendprofile, :index]
  before_action :set_following, only: :index

  def index
    @users = User.where.not(id: @current_user.id)
    @usersToFollow = @users.reject {|friend| @following.include?(friend.id)}
    @followersList = Array.new
    for user in @usersToFollow do
      @followers = user.followers.all
      @followersList.push @followers        
    end
    if @usersToFollow
      build_suggestions(@usersToFollow, @followersList)
      render json: { message: @finalList }, status: :ok
    else
      render json: { message: [] }, status: :ok
    end
  end

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
    render json: {message: @profile}, status: :ok
  end

  def friendprofile
    puts('friend profile')
    render json: {message: @profile}, status: :ok
  end

  private

  def find_friend
    @friend = User.find_by(username: params[:username])
    details(@friend)
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'User not found' }, status: :not_found
  end

  def self_details
    details(@current_user)
  end

  def user_params
    params.permit(
      :photoURL, :name, :username, :email, :password
    )
  end

  def details(user)
    @followers = user.followers.all
    @following = Following.where(user_id: user.id)
    @posts = Post.where(author: user).order(created_at: :desc).limit(10)
    @likes = Like.where(user_id_id: user, post_id_id: @posts)
    @currentlyFollowing = false
    @isSelf = true

    if params[:username]
      mappedFriends = @followers.map {|friends| friends.user_id}
      if mappedFriends.include?(@current_user.id)
        @currentlyFollowing = true
      end
      @isSelf = false
    end

    @likesBySelf = Array.new
    @finalPosts = Array.new
    for post in @posts do
      author = User.find_by_id(post.author_id)
      @likes = Like.find_by(post_id_id: post.id, user_id_id: @current_user.id)
      @allLikes = Like.find_by(post_id_id: post.id)
      new_post = {
        post: post.post,
        likes: @allLikes,
        createdAt: post.created_at,
        _id:post.id,
        author: {
          username: author.username,
          name: author.name,
          photoURL: author.photoURL
        }
      }
      if new_post['likes'].nil?
        new_post['likes'] = []
      end
      @finalPosts.push(new_post)
      if @likes
        @likesBySelf.push true
      else
        @likesBySelf.push false
      end
    end

    @profile = { 
      username: user.username,
      following: @following.length,
      followers: @followers.length,
      photoURL: user.photoURL,
      name: user.name,
      posts: @finalPosts,
      likesMap: @likesBySelf,
      self: @isSelf,
      currentlyFollowing: @currentlyFollowing
    }
  end
  
  def set_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    @user = JsonWebToken.decode({token: header})
    @current_user = User.find(@user[:user_id])
  end

  def set_following
    @following = Following.where(user_id: @current_user).pluck(:friend_id)
  end

  def build_suggestions(users, followers)
    @finalList = Array.new
    users.each_index {|index| 
      new_user = {
        username: users[index].username,
        followers: followers[index],
        photoURL: users[index].photoURL
      }
      @finalList.push(new_user)
    }
  end
end