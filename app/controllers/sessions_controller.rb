class SessionsController < ApplicationController
  before_action :require_no_authentication, only: [:new, :create]

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].strip.downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in @user, params[:session][:remember_me]
      redirect_back_or @user.next_feed
    else
      flash.now[:alert] = 'Invalid email/password combination.'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
