class AuthenticationController < ApplicationController
  before_action :authorize_request, except: [:login, :refresh]
  before_action :set_user, only: :logout
  wrap_parameters false  

  # POST /auth/login
  def login
    @user = User.find_by_username(params[:username])
    if @user&.matching_password?(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      refresh_token = JsonWebToken.encode(user_id: @user.id, exp: 72.hours.from_now)
      @existing_token = Token.find_by_username(params[:username])
      if(@existing_token)
        @existing_token.destroy
      end
      @new_token = Token.new({ username:@user.username, token: refresh_token })
      @new_token.save!
      render json: { access_Token: token, refresh_Token: refresh_token }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  def logout
    @existing_token = Token.find_by_username(@current_user.username)
    if(@existing_token)
      @existing_token.destroy
    end
    render json: {message: 'Logged Out Successfully'}, status: :ok
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

  def set_user      
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    @user = JsonWebToken.decode({token: header})
    @current_user = User.find(@user[:user_id])
  end

end