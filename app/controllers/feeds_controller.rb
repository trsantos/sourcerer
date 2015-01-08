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
    fj_feed = Feedjira::Feed.fetch_and_parse url
    if fj_feed.is_a? Integer
      flash.now[:alert] = "Feed does not exist or could not be fetched."
      render 'new'
      return
    end
    @feed = Feed.new(title:    fj_feed.title,
                     feed_url: url,
                     site_url: fj_feed.url)
    if Feed.find_by(feed_url: url)
      flash.now[:info] = "Feed is already in the database."
      render 'new'
    elsif
      @feed.save
      redirect_to @feed
    end
  end
end
