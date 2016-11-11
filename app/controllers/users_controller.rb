class UsersController < ApplicationController
  before_action :require_no_authentication, only: [:new, :create]
  before_action :logged_in_user, except: [:new, :create]
  before_action :correct_user,   only: [:show, :edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash.now[:success] = 'Profile updated.'
    end
    render 'edit'
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:primary] = 'User deleted succesfully.'
    redirect_to root_url
  end

  def follow_top_sites
    user = current_user
    Feed.where(top_site: true).shuffle.each do |f|
      user.subscriptions.find_or_create_by(feed: f)
    end
    flash[:primary] = 'Ok, done! Happy reading.'
    redirect_to user.next_feed
  end

  private

  def user_params
    params
      .require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user == @user
  end
end
