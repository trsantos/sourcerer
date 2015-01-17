class FeedsController < ApplicationController
  include ApplicationHelper
  
  before_action :logged_in_user, only: [:index]
  
  def index
    @feeds = Feed.all.paginate(page: params[:page])
  end

  def show
    @feed = Feed.find(params[:id])
    @feed.update
    if logged_in? and current_user.following?(@feed)
      Subscription.find_by(feed_id: @feed.id).update_attribute(:visited_at, Time.zone.now)
    end
    @entries = @feed.entries
  end

  def new
  end
  
  def create
    url = params[:feed][:feed_url]
    feed = Feed.find_by(feed_url: url) || Feed.create(feed_url: url)
    redirect_to feed
  end
end
