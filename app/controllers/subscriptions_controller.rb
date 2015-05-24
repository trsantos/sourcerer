class SubscriptionsController < ApplicationController
  include ApplicationHelper
  include FeedsHelper
  
  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @subscriptions = current_user.subscriptions.sort_by { |s| sub_title(s.feed) || "" }
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
    # Enable next line when it becomes impossible to update all feeds every hour
    # Also remember to change Feed.update_interval
    #
    # current_user.delay.update_subscriptions
    subs = current_user.subscriptions.order(starred: :desc, updated_at: :desc)
    subs.each do |s|
      redirect_to s.feed and return if s.updated? and (s.starred? or s.visited_at < Date.today)
    end
    subs.each do |s|
      redirect_to s.feed and return if s.updated?
    end
    flash[:info] = "You have no updated feeds. Check back later!"
    redirect_to root_url
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
