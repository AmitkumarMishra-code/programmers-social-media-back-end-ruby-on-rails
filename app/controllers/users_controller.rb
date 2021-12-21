class UsersController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :find_friend, only: [:friend_profile]
  before_action :self_details, only: :self_profile
  before_action :set_user, only: [:self_profile, :friend_profile, :index]
  before_action :set_following, only: :index

  def index
    @users = User.where.not(id: @current_user.id)
    @users_to_follow = @users.reject {|friend| @following.include?(friend.id)}
    @followers_list = Array.new
    for user in @users_to_follow do
      @followers = user.followers.all
      @followers_list.push @followers        
    end
    if @users_to_follow
      build_suggestions(@users_to_follow, @followers_list)
      render json: { message: @final_list }, status: :ok
    else
      render json: { message: [] }, status: :ok
    end
  end

  # POST /users
  def create
    image = Cloudinary::Uploader.upload(params[:profilePic])
    photo_url = image["url"]
    @user = User.new({photoURL: photo_url, name: params[:name], username: params[:username], email: params[:email], password: params[:password]})
    if @user.save
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def self_profile
    render json: {message: @profile}, status: :ok
  end

  def friend_profile
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
      :profilePic, :name, :username, :email, :password
    )
  end

  def details(user)
    @followers = user.followers.all
    @following = Following.where(user_id: user.id)
    @posts = Post.where(author: user).order(created_at: :desc).limit(10)
    @likes = Like.where(user_id_id: user, post_id_id: @posts)
    @currently_following = false
    @is_self = true

    if params[:username]
      mappedFriends = @followers.map {|friends| friends.user_id}
      if mappedFriends.include?(@current_user.id)
        @currently_following = true
      end
      @is_self = false
    end

    @likes_by_self = Array.new
    @final_posts = Array.new
    for post in @posts do
      author = User.find_by_id(post.author_id)
      @likes = Like.find_by(post_id_id: post.id, user_id_id: @current_user.id)
      @all_likes = Like.find_by(post_id_id: post.id)
      new_post = {
        post: post.post,
        likes: @all_likes,
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
      @final_posts.push(new_post)
      if @likes
        @likes_by_self.push true
      else
        @likes_by_self.push false
      end
    end

    @profile = { 
      username: user.username,
      following: @following.length,
      followers: @followers.length,
      photoURL: user.photoURL,
      name: user.name,
      posts: @final_posts,
      likesMap: @likes_by_self,
      self: @is_self,
      currentlyFollowing: @currently_following
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
    @final_list = Array.new
    users.each_index {|index| 
      new_user = {
        username: users[index].username,
        followers: followers[index],
        photoURL: users[index].photoURL
      }
      @final_list.push(new_user)
    }
  end
end