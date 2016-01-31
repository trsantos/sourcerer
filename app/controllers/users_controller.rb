class UsersController < ApplicationController
  before_action :require_no_authentication, only: [:new, :create]
  before_action :logged_in_user, except: [:new, :create]
  before_action :correct_user,   only: [:show, :edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
    @topics = Topic.all
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
    flash[:success] = 'Profile updated.' if @user.update_attributes(user_params)
    render 'edit'
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:primary] = 'User deleted.'
    redirect_to users_url
  end

  def update_topics
    user = current_user
    params[:topic].each do |t, v|
      t = Topic.find_by(name: t)
      user.unfollow_topic(t) if v == '0'
      user.follow_topic(t) if v == '1'
    end
    set_flash_message
    redirect_to user.next_feed
  end

  private

  def user_params
    params.require(:user)
      .permit(:name, :email, :password, :password_confirmation)
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user == @user
  end

  # Used when updating topics
  def set_flash_message
    if current_user.subscriptions.any?
      flash[:primary] = 'Ok, done! Happy reading.'
    else
      flash[:alert] = 'Sourcerer is useful only if you subscribe to some '\
                      'feeds. Please, choose some topics or import an OPML'\
                      "file, if you're coming from another reader."
    end
  end
end
