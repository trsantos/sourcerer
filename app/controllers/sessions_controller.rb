class SessionsController < ApplicationController
  force_ssl unless Rails.env.development?

  def new
    if logged_in?
      redirect_to current_user
    end
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      redirect_back_or next_path
    else
      flash.now[:alert] = 'Invalid email/password combination' # Not quite right!
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
