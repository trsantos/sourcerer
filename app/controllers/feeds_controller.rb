class FeedsController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user
  before_action :set_user
  before_action :update_last_activity
  before_action :expiration_date
  before_action :mark_subscription_as_visited, only: [:show]
  before_action :no_updated_feeds_left, only: [:show]

  def index
    @feeds = Feed.order(title: :asc).all
  end

  def show
    @feed = Feed.find(params[:id])
    @entries = @feed.entries.order(pub_date: :desc)
    @only_images = @feed.only_images?
    @subscription = @user.subscriptions.find_by(feed_id: @feed.id)
  end

  def new
    return unless params[:feed]
    feed = Feed.find_or_create_by(feed_url: process_url(params[:feed]))
    redirect_to feed
  end

  def create
    url = params[:feed][:feed_url]
    feed = Feed.find_or_create_by(feed_url: process_url(url))
    feed.update
    redirect_to feed
  end

  private

  def set_user
    @user = current_user
  end

  def expiration_date
    return unless Time.current > current_user.expiration_date
    redirect_to billing_expired_path
  end

  def mark_subscription_as_visited
    sub = current_user.subscriptions.find_by(feed_id: params[:id])
    if sub.updated?
      sub.update_attributes(visited_at: Time.current, updated: false)
    end
  rescue
    nil
  end

  def update_last_activity
    current_user.update_attribute :last_activity, Time.current
  end

  def no_updated_feeds_left
    return if current_user.subscriptions.exists?(updated: true)
    flash.now[:info] = 'You have no updated feeds right now. Check back later!'
  end
end
