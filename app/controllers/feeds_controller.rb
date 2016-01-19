class FeedsController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user
  before_action :set_user
  before_action :expiration_date
  before_action :mark_as_read, only: [:show]
  before_action :no_updated_feeds_left, only: [:show]

  def index
    @feeds = Feed.order(title: :asc).all
  end

  def show
    @feed = Feed.find(params[:id])
    @next_feed = @user.next_feed
    @entries = @feed.entries.order(updated_at: :desc) unless @feed.fetching
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

  def expiration_date
    return unless Time.current > @user.expiration_date
    redirect_to billing_expired_path
  end

  def no_updated_feeds_left
    return unless @subscription
    return if @user.subscriptions.exists?(updated: true)
    flash.now[:info] = 'You have no updated feeds right now. Check back later!'
  end

  def mark_as_read
    @subscription = @user.subscriptions.find_by(feed_id: params[:id])
    @last_visit = @subscription.visited_at
    if @subscription.updated?
      @subscription.update_attributes(visited_at: Time.current, updated: false)
    end
  rescue
    nil
  end
end
