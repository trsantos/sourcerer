module ApplicationHelper
  def full_title(page_title = '')
    base_title = "Reader"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def in_feeds_show
    if params[:controller] == "feeds" && params[:action] == "show"
      " show-for-medium-up"
    else
      ""
    end
  end

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:alert] = "Please log in."
      redirect_to login_url
    end
  end

  def find_or_create_feed(url)
    unless url.start_with?('http:') or url.start_with?('https:')
      url = 'http://' + url
    end
    Feed.find_by(feed_url: url) || Feed.create(feed_url: url)
  end
end
