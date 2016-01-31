class OpmlController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user
  before_action :check_for_opml_file, only: [:create]

  def new
  end

  def create
    user = current_user
    contents = params[:opml][:opml_file].read
    opml = OpmlSaw::Parser.new(contents)
    opml.parse
    opml.feeds.each do |f|
      new_feed = Feed.find_or_create_by(feed_url: process_url(f[:xml_url]))
      user.follow(new_feed)
    end
    flash[:primary] = 'OPML file imported. Happy reading!'
    redirect_to user.next_feed
  rescue
    flash.now[:alert] = 'The was a problem with the OPML file import.'
    render 'new'
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

  private

  def check_for_opml_file
    return if params[:opml].present?
    flash.now[:alert] = 'Please, select the OPML file that you want to import.'
    render 'new'
  end
end
