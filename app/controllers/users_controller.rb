class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :expiration_date_presence, only: [:edit]
  before_action :correct_user,   only: [:show, :edit, :update, :destroy]
  before_action :admin_user,     only: [:destroy, :index]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @topics = Topic.all
  end

  def new
    if logged_in?
      flash[:info] = 'Already logged in.'
      redirect_to edit_user_path current_user
    end
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.update_attribute(:expiration_date, 1.week.from_now)
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
    flash[:info] = 'User deleted.'
    redirect_to users_url
  end

  def update_topics
    user = current_user
    user.topics = []
    params[:topic].each do |t, v|
      t = Topic.find_by(name: t)
      user.unfollow_topic(t) if v == '0'
      user.follow_topic(t) if v == '1'
    end
    flash[:success] = 'Done. Happy reading!'
    redirect_to next_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to edit_user_path current_user unless current_user?(@user)
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
