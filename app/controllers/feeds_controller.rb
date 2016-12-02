class FeedsController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user
  before_action :set_user
  before_action :check_expiration_date
  before_action :set_subscription, only: [:show]
  before_action :unread_feeds, only: [:show]
  after_action :mark_feed_as_read, only: [:show]

  def show
    @feed = Feed.find(params[:id])
    @entries = @feed.entries.order(pub_date: :desc) unless @feed.fetching
  end

  def new
    return unless params[:feed]
    feed = Feed.find_or_create_by(feed_url: process_url(params[:feed]))
    redirect_to feed
  end

  def create
    url = params[:feed][:feed_url]
    feed = Feed.find_or_create_by(feed_url: process_url(url))
    redirect_to feed
  end

  private

  def set_user
    @user = current_user
    @user.touch
  end

  def check_expiration_date
    return unless @user.feeds.count > Payment.feed_limit &&
                  Time.current > @user.expiration_date
    redirect_to new_payment_path
  end

  def set_subscription
    @subscription = @user.subscriptions.find_by(feed_id: params[:id])
  end

  def mark_feed_as_read
    return unless @subscription.updated?
    @subscription.update_attributes(visited_at: Time.current, updated: false)
  rescue
    nil
  end

  def unread_feeds
    return unless @subscription
    return if @user.subscriptions.exists?(updated: true)
    flash.now[:primary] =
      'You have no updated feeds right now. Check back later!'
  end
end
