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
    if t == "Computers"
      return [
        "http://techcrunch.com/feed/",
        "http://www.wired.com/feed/",
        "http://feeds2.feedburner.com/ziffdavis/pcmag/breakingnews",
        "http://feeds2.feedburner.com/techradar/allnews",
        "http://feeds.arstechnica.com/arstechnica/index/"
      ]
    elsif t == "News"
      return [
        "http://rss.news.yahoo.com/rss/topstories",
        "http://rss.cnn.com/rss/cnn_topstories.rss",
        "http://www.huffingtonpost.com/feeds/index.xml",
        "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
        "http://www.theguardian.com/uk/rss"
      ]
    elsif t == "Business"
      return [
        "http://feeds.wsjonline.com/wsj/xml/rss/3_7011.xml",
        "http://www.newslookup.com/rss/business/bloomberg.rss",
        "http://feeds.reuters.com/reuters/topNews",
        "http://rss.cnn.com/rss/money_topstories.rss",
        "http://feeds.marketwatch.com/marketwatch/topstories/"
      ]
    elsif t == "Games"
      return [
        "http://feeds.ign.com/ign/games-all",
        "http://store.steampowered.com/feeds/news.xml",
        "http://news.xbox.com/feed/stories",
        "http://feeds.feedburner.com/psblog",
        "http://www.gamespot.com/feeds/mashup/"
      ]
    elsif t == "Science"
      return [
        "http://www.livescience.com/home/feed/site.xml",
        "http://feeds.sciencedaily.com/sciencedaily",
        "http://feeds.nationalgeographic.com/ng/News/News_Main",
        "http://phys.org/rss-feed/breaking/",
        "http://www.theguardian.com/science/rss"
      ]
    else
      return []
    end
  end
end
