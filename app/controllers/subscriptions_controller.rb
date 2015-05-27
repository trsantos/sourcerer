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

  def old_next
    # Enable next line when it becomes impossible to update all feeds every hour
    # Also remember to change Feed.update_interval
    #
    # current_user.delay.update_subscriptions
    subs = current_user.subscriptions.order(starred: :desc, updated_at: :desc)
    next_sub = nil
    subs.each do |s|
      if s.updated?
        if s.starred? or s.visited_at.nil? or s.visited_at < 1.day.ago
          redirect_to s.feed and return
        end
        next_sub ||= s
      end
    end

    if next_sub
      redirect_to next_sub.feed and return
    end

    flash[:info] = "You have no updated feeds. Check back later!"
    redirect_to root_url
  end

  def next
    if current_user.next_feed.nil?
      current_user.set_next_feed
    end

    if nf = current_user.next_feed
      redirect_to Feed.find(nf.feed_id)
      nf.destroy
      current_user.delay.set_next_feed
      return
    else
      flash[:info] = "You have no updated feeds. Check back later!"
      redirect_to root_url
    end
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
