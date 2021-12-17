class LikesController < ApplicationController
  before_action :authorize_request
  before_action :set_like, only: [:destroy]
  # wrap_parameters false  


  # POST /likes
  def create
    @like = Like.new(like_params)

    if @like.save
      render json: @like, status: :created, location: @like
    else
      render json: @like.errors, status: :unprocessable_entity
    end
  end

  # DELETE /likes
  def destroy
    @like.destroy
    render json: {message: "unliked the post"}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      begin
      @like = Like.find_by!(post_id: params[:id], user_id: params[:user_id_id])
      puts(@like)
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def like_params
      params.require(:like).permit(:user_id_id, :post_id_id)
    end
end
