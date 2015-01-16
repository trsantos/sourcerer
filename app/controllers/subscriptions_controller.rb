class SubscriptionsController < ApplicationController
  include ApplicationHelper
  
  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @subscriptions = current_user.subscriptions.paginate(page: params[:page])
  end

  def create
    feed = Feed.find(params[:feed_id])
    current_user.follow(feed)
    redirect_to feed
  end

  def edit
    @subscription = Subscription.find(params[:id])
  end

  def update
    @subscription = Subscription.find(params[:id])
    if @subscription.update_attributes(sub_params)
      feed = Feed.find(@subscription.feed_id)
      redirect_to feed
    end
  end

  def destroy
    feed = Feed.find(Subscription.find(params[:id]).feed_id)
    current_user.unfollow(feed)
    redirect_to feed
  end

  def next
    current_user.subscriptions.shuffle.each do |s|
      f = s.feed
      f.update
      if s.updated?
        redirect_to f
        return
      end
    end
    redirect_to root_url
    return
  end

  private

  def sub_params
    params.require(:subscription).permit(:title, :site_url, :starred)
  end

  def correct_user
    @user = User.find(Subscription.find(params[:id]).user_id)
    redirect_to root_url unless current_user?(@user) or current_user.admin?
  end
end
