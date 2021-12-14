class AuthenticationController < ApplicationController
  before_action :authorize_request, except: [:login, :refresh]
  wrap_parameters false  

  # POST /auth/login
  def login
    @user = User.find_by_username(params[:username])
    if @user&.matching_password?(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      refresh_token = JsonWebToken.encode(user_id: @user.id, exp: 72.hours.from_now)
      @existing_token = Token.find_by_username(params[:username])
      @existing_token.destroy
      @new_token = Token.new({ username:@user.username, token: refresh_token })
      @new_token.save!
      render json: { access_Token: token, refresh_Token: refresh_token }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  # POST /auth/refresh
  def refresh
    begin
      @decoded = JsonWebToken.decode(refresh_params)
      token = JsonWebToken.encode(user_id: @decoded[:user_id])
      render json: { access_Token: token }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  private

  def login_params
    params.permit(:username, :password)
  end

  def refresh_params
    params.permit(:token)
  end
end