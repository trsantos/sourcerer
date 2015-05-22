class FeedsController < ApplicationController
  include ApplicationHelper
  
  before_action :logged_in_user, only: [:index]
  after_action  :mark_subscription_as_visited, only: [:show]
  
  def index
    @feeds = Feed.all.sort_by { |f| f.title || "" }
  end

  def show
    @feed = Feed.find(params[:id])
    @entries = @feed.entries
  end

  def new
    if params[:feed]
      feed = find_or_create_feed(params[:feed])
      redirect_to feed
    end
  end
  
  def create
    url = params[:feed][:feed_url]
    feed = find_or_create_feed(url)
    redirect_to feed
  end

  private

  def mark_subscription_as_visited
    if logged_in? and current_user.following?(@feed)
      current_user.subscriptions.find_by(feed_id: @feed.id).update_attribute(:visited_at, Time.zone.now)
    end
  end

end
