class FeedsController < ApplicationController
  include ApplicationHelper
  
  before_action :logged_in_user, only: [:index, :show, :new, :create]
  after_action  :mark_subscription_as_visited, only: [:show]
  
  def index
    @feeds = Feed.all.sort_by { |f| f.title || "" }
  end

  def show
    @feed = Feed.find(params[:id])
    if @feed.created_at > 1.hour.ago
      # TODO: Use Ajax to reload the page when the fetch is done.
      flash.now[:info] = new_feed_message
      @feed.delay.update
    end
    @entries = @feed.entries
  end

  def new
    if params[:feed]
      feed = Feed.find_or_create_by(feed_url: process_url(params[:feed]))
      redirect_to feed
    end
  end
  
  def create
    url = params[:feed][:feed_url]
    feed = Feed.find_or_create_by(feed_url: process_url(url))
    redirect_to feed
  end

  private

  def mark_subscription_as_visited
    if logged_in? and current_user.following?(@feed)
      current_user.subscriptions.find_by(feed_id: @feed.id).update_attribute(:visited_at, Time.zone.now)
    end
  end

  def new_feed_message
    "You've just added a new feed to Sourcerer! We're going to fetch it shortly but you may subscribe to it right now and everything will be fine. This is going to be fixed soon..."
  end

end
