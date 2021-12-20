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
    @posts = Post.where(author: @following).order(created_at: :desc).limit(20)
    puts(@posts)
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
    
    render json: { message: { posts: @finalPosts, likesMap: @likesBySelf } }, status: :ok
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
      @following = Following.where(user_id: @current_user).pluck(:friend_id)
    end

end
