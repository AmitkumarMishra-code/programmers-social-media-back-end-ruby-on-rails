class PostsController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :set_post, only: [:destroy]
  before_action :set_user
  before_action :set_following, only: [:feed]
  wrap_parameters false  

  # GET /posts
  def index
    @posts = Post.where(author: @current_user)
    render json: @posts, status: :ok
  end

  def feed
    @posts = Post.where(author: @following).order(created_at: :desc).limit(10)
    puts(@posts)
    render json: @posts, status: :ok
  end

  # POST /posts
  def create
    @post = Post.new({author: @current_user, post: params[:post_body]})

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    def set_user      
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      @user = JsonWebToken.decode({token: header})
      @current_user = User.find(@user[:user_id])
    end

    def set_following
      puts(@current_user)
      @following = Following.where(user_id: @current_user).pluck(:friend_id)
      puts(@following)
    end

end
