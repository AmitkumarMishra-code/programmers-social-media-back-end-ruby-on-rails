class TokensController < ApplicationController
  # before_action :authorize_request
  before_action :set_token, only: [:show, :update, :destroy]

  # GET /tokens
  def index
    @tokens = Token.all

    render json: @tokens
  end

  # POST /tokens
  def create
    @token = Token.new(token_params)

    if @token.save
      render json: @token, status: :created, location: @token
    else
      render json: @token.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tokens/1
  def destroy
    @token.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_token
      @token = Token.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def token_params
      params.require(:token).permit(:username, :token)
    end
    
end
