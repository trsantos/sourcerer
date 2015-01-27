class FeedsController < ApplicationController
  include ApplicationHelper
  
  before_action :logged_in_user, only: [:index]
  
  def index
    @feeds = Feed.all
  end

  def show
    @feed = Feed.find(params[:id])
    @feed.update
    if logged_in? and current_user.following?(@feed)
      current_user.subscriptions.find_by(feed_id: @feed.id).update_attribute(:visited_at, Time.zone.now)
    end
    @entries = @feed.entries
  end

  def new
  end
  
  def create
    url = params[:feed][:feed_url]
    feed = find_or_create_feed(url)
    redirect_to feed
  end
end
