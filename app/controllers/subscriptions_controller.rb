class SubscriptionsController < ApplicationController
  include ApplicationHelper
  include FeedsHelper

  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @subscriptions =
      current_user.subscriptions.includes(:feed).order(starred: :desc)
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
    set_update_params
    @subscription = Subscription.find(params[:id])
    @subscription.update_attributes(sub_params)
    redirect_to @subscription.feed
  end

  def destroy
    feed = Subscription.find(params[:id]).feed
    current_user.unfollow(feed)
    redirect_to feed
  end

  def next
    next_sub =
      current_user.subscriptions
      .where(updated: true).order(starred: :desc, visited_at: :asc).first
    if next_sub
      redirect_to next_sub.feed
      return
    end
    flash[:info] = 'You have no updated feeds. Check back later!'
    redirect_to root_url(from_next: true)
  end

  private

  def sub_params
    params.require(:subscription).permit(:title, :site_url, :starred)
  end

  def set_update_params
    title = params[:subscription][:title]
    params[:subscription][:title] = nil if title.blank?

    site_url = params[:subscription][:site_url]
    params[:subscription][:site_url] = process_url site_url
  end

  def next_updated_sub
    starred_order = rand < 0.8 ? :desc : :asc
    current_user.subscriptions.where(updated: true)
      .order(starred: starred_order, visited_at: :asc).first
  end

  def correct_user
    @user = User.find(Subscription.find(params[:id]).user_id)
    redirect_to root_url unless current_user?(@user) || current_user.admin?
  end
end
