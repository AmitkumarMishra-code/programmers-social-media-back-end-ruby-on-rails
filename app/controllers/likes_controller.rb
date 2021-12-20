class LikesController < ApplicationController
  before_action :authorize_request
  before_action :set_like, only: [:destroy]
  before_action :set_user
  before_action :set_post, only: [:create]
  # wrap_parameters false  


  # POST /like
  def create
    @like = Like.new({post_id: @post, user_id: @current_user})

    if @like.save
      render json: @like, status: :ok, location: @like
    else
      render json: @like.errors, status: :unprocessable_entity
    end
  end

  # DELETE /like
  def destroy
    @like.destroy
    render json: {message: "unliked the post"}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      begin
      @like = Like.find_by!(post_id: params[:id], user_id: @current_user)
      puts(@like)
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :not_found
      end
    end

    def set_user      
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      @user = JsonWebToken.decode({token: header})
      @current_user = User.find(@user[:user_id])
    end

    def set_post
      begin
      @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :not_found
      end
    end

end
