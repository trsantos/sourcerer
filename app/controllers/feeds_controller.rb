class FeedsController < ApplicationController
  def show
    @feed = Feed.find(params[:id])
    @feed.update
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

  private

  def create_feed(url)
    fj_feed = Feedjira::Feed.fetch_and_parse url
    if fj_feed.is_a? Integer
      return nil
    end
    feed = Feed.new(title:    fj_feed.title,
                    feed_url: fj_feed.url,
                    site_url: fj_feed.url)
    # entries = fj_feed.entries
    # 5.times do |n|
    #   if entries[n]
    #     feed.entries.new(title:       entries[n].title,
    #                      description: entries[n].content,
    #                      pub_date:    entries[n].published,
    #                      url:         entries[n].url)
    #   end
    # end
    return feed
  end

end
