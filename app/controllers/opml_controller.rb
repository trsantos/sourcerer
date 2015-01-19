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
      current_user.follow(find_or_create_feed(f[:xml_url]))
    end
    redirect_to next_path
  end
end
