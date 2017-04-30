class OpmlController < ApplicationController
  include ApplicationHelper

  before_action :logged_in_user
  before_action :check_for_opml_file, only: [:create]
  before_action :set_user, only: [:create]
  before_action :set_opml, only: [:create]

  def new
  end

  def create
    @opml.body.outlines.each do |f|
      feed = Feed.find_or_create_by(feed_url: f.xml_url.to_s)
      @user.subscriptions.find_or_create_by(feed: feed)
    end
    flash[:primary] = 'OPML file imported. Happy reading!'
    redirect_to @user.next_feed
  rescue
    flash.now[:alert] = 'The was a problem with the OPML file import.'
    render 'new'
  end

  def export
    f = export_head
    current_user.subscriptions.each do |s|
      f += export_sub_entry(s)
    end
    f += export_tail
    f.gsub! '&', '&amp;'
    send_data f, filename: 'sourcerer.opml'
  end

  private

  def check_for_opml_file
    return if params[:opml].present?
    flash.now[:alert] = 'Please, select the OPML file that you want to import.'
    render 'new'
  end

  def set_user
    @user = current_user
  end

  def set_opml
    contents = params[:opml][:opml_file].read
    @opml = Feedjira::Feed.parse contents
  end

  def export_head
    "<opml version=\"2.0\">\n" \
    "  <head>\n" \
    "    <title>OPML from Sourcerer</title>\n" \
    "  </head>\n" \
    "  <body>\n"
  end

  def export_sub_entry(s)
    '    <outline type="rss" text="' + s.feed.title.to_s +
      '" xmlUrl="' + s.feed.feed_url + "\"/>\n"
  end

  def export_tail
    "  </body>\n" \
    "</opml>\n"
  end
end
