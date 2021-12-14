class PostsController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :set_post, only: [:destroy]
  before_action :set_user
  wrap_parameters false  

  # GET /posts
  def index
    @posts = Post.all

    render json: @posts
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

end
