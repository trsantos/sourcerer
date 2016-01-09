class PasswordResetsController < ApplicationController
  before_action :find_user,        only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
    redirect_to edit_user_path(current_user) if logged_in?
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.delay.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:alert] = 'Email address not found'
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      log_in @user
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Before filters

  def find_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    redirect_to root_url unless @user && @user.authenticated?(:reset,
                                                              params[:id])
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?
    flash[:alert] = 'Password reset has expired.'
    redirect_to new_password_reset_url
  end
end
