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
      current_user.follow(Feed.find_or_create_by(feed_url: process_url(f[:xml_url])))
    end
    flash[:info] = "OPML file imported. Happy reading!"
    redirect_to next_path
  end
end
