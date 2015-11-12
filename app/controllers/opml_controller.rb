class OpmlController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user

  def new
  end

  def create
    contents = params[:opml][:opml_file].read
    opml = OpmlSaw::Parser.new(contents)
    opml.parse
    opml.feeds.each do |f|
      new_feed = Feed.find_or_create_by(feed_url: process_url(f[:xml_url]))
      current_user.follow(new_feed)
      new_feed.delay.update if Rails.env.production? && new_feed.created_at > 10.seconds.ago
    end
    flash[:info] = 'OPML file imported. Happy reading!'
    redirect_to next_path
  end

  def export
    @subscriptions = current_user.subscriptions
    f  = "<opml version=\"2.0\">\n"
    f += "  <head>\n"
    f += "    <title>OPML from Sourcerer</title>\n"
    f += "  </head>\n"
    f += "  <body>\n"
    current_user.subscriptions.each do |s|
      f += '    <outline type="rss" text="' + s.feed.title.to_s +
           '" xmlUrl="' + s.feed.feed_url + '"/>' + "\n"
    end
    f += "  </body>\n"
    f += "</opml>\n"
    f.gsub! '&', '&amp;'
    send_data f, filename: 'sourcerer.opml'
  end
end
