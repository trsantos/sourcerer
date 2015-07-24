class FeedsController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user
  before_action :check_expiration_date
  after_action :mark_subscription_as_visited, only: [:show]

  def index
    @feeds = Feed.order(title: :asc).all
  end

  def show
    @feed = Feed.find(params[:id])
    # TODO: Use Ajax to reload the page when the fetch is done.
    @feed.update if @feed.created_at > 1.minute.ago
    @entries = @feed.entries
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
    if user.expiration_date.nil?
      user.update_attribute(:expiration_date, 1.week.from_now)
    elsif Time.current > user.expiration_date
      redirect_to billing_expired_path
    end
  end

  def mark_subscription_as_visited
    return unless current_user.following?(@feed)
    sub = current_user.subscriptions.find_by(feed_id: @feed.id)
    sub.update_attributes(visited_at: Time.zone.now, updated: false)
  end
end
