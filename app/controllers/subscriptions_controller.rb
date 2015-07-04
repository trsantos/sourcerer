class SubscriptionsController < ApplicationController
  include ApplicationHelper
  include FeedsHelper

  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @subscriptions = current_user.subscriptions.includes(:feed).where(starred: true).sort_by { |s| s.title || s.feed.title || "" }
    @subscriptions += current_user.subscriptions.includes(:feed).where(starred: false).sort_by { |s| s.title || s.feed.title || "" }
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

    title = params[:subscription][:title]
    if title && title.blank?
      params[:subscription][:title] = nil
    end

    site_url = params[:subscription][:site_url]
    if site_url
      if site_url.blank?
        params[:subscription][:site_url] = nil
      else
        params[:subscription][:site_url] = process_url site_url
      end
    end

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
    next_sub = current_user.subscriptions.where(updated: true).order(starred: :desc, visited_at: :asc).first
    if next_sub
      redirect_to next_sub.feed and return
    end
    flash[:info] = "You have no updated feeds. Check back later!"
    redirect_to root_url({ :from_next => true })
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
