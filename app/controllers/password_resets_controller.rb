class PasswordResetsController < ApplicationController
  before_action :require_no_authentication
  before_action :set_user, only: [:edit, :update]

  def new
  end

  def create
    user = User.find_by(email: params[:password_reset][:email].strip.downcase)
    user.send_password_reset if user
    flash[:primary] = 'Email sent with password reset instructions.'
    redirect_to root_url
  end

  def edit
  end

  def update
    if @user.password_reset_sent_at < 2.hours.ago
      flash[:alert] = 'Password reset has expired.'
      redirect_to new_password_reset_path
    elsif @user.update_attributes(user_params)
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

  def set_user
    @user = User.find_by!(password_reset_token: params[:id])
  rescue
    redirect_to root_url
  end
end
