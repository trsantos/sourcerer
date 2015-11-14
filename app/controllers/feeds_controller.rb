class FeedsController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user
  before_action :expiration_date_presence
  before_action :check_expiration_date
  before_action :update_last_activity
  # before_action :update_feeds, only: [:show]
  after_action :mark_subscription_as_visited, only: [:show]

  def index
    @feeds = Feed.order(title: :asc).all
  end

  def show
    @feed = Feed.find(params[:id])
    # TODO: Use Ajax to reload the page when the fetch is done.
    @feed.update if @feed.created_at > 1.minute.ago || Rails.env.development?
    @entries = @feed.entries.order(pub_date: :desc)
    @only_images = @feed.only_images?
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

  def check_expiration_date
    user = current_user
    return unless Time.current > user.expiration_date
    redirect_to billing_expired_path
  end

  def update_feeds
    user = current_user
    t = user.subscriptions_updated_at
    return unless t.nil? || t < 2.hours.ago
    user.update_attribute(:subscriptions_updated_at, Time.zone.now)
    user.feeds.all.each { |f| f.delay.update }
  end

  def mark_subscription_as_visited
    sub = current_user.subscriptions.find_by(feed_id: @feed.id)
    if sub.updated?
      sub.update_attributes(visited_at: Time.zone.now, updated: false)
    end
  rescue
    nil
  end

  def update_last_activity
    current_user.update_attribute :last_activity, Time.current
  end
end
