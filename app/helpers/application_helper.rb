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

  def get_feeds(t)
    if t == "Technology"
      return ["http://www.theverge.com/rss/index.xml",
              "http://www.engadget.com/rss.xml",
              "http://feeds.gawker.com/lifehacker/full",
              "http://readwrite.com/rss.xml",
              "http://techcrunch.com/feed/",
              "http://feeds.gawker.com/gizmodo/full",
              "http://www.wired.com/feed/",
              "http://feeds.mashable.com/Mashable",
              "http://feeds.arstechnica.com/arstechnica/index/",
              "http://rss.slashdot.org/Slashdot/slashdot"]
    elsif t == "News"
      return ["http://rss.cnn.com/rss/edition.rss",
              "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
              "http://www.npr.org/rss/rss.php?id=1001",
              "http://feeds.abcnews.com/abcnews/topstories",
              "http://feeds.bbci.co.uk/news/rss.xml",
              "http://feeds.feedburner.com/foxnews/latest",
              "http://feeds.reuters.com/reuters/topNews",
              "http://www.theguardian.com/uk/rss",
              "http://rssfeeds.usatoday.com/usatoday-NewsTopStories",
              "http://time.com/feed/"]
    elsif t == "Sports"
      return []
    else
      return []
    end
  end
end
