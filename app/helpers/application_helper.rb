module ApplicationHelper

  def full_title(page_title = '')
    base_title = "Sourcerer"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def in_feeds_show
    if params[:controller] == "feeds" && params[:action] == "show"
      " show-for-medium-up no-shadow"
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

  def check_for_trial_expiration
    if current_user.on_trial? and current_user.created_at < 1.week.ago
      flash[:alert] = "Your trial period has just ended. It's time to subscribe to Sourcerer!"
      redirect_to billing_path
    end
  end

  def process_url(url)
    unless url.start_with?('http:') or url.start_with?('https:')
      url = 'http://' + url
    end
    url
  end

  def get_feeds(topic)
    t = topic.name
    if t == "Computers"
      return [
        "http://techcrunch.com/feed/",
        "http://www.wired.com/feed/",
        "http://feeds.arstechnica.com/arstechnica/index/"
      ]
    elsif t == "News"
      return [
        "http://rss.cnn.com/rss/cnn_topstories.rss",
        "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml",
        "http://www.theguardian.com/uk/rss"
      ]
    elsif t == "Business"
      return [
        "http://feeds.wsjonline.com/wsj/xml/rss/3_7011.xml",
        "http://www.newslookup.com/rss/business/bloomberg.rss",
        "http://feeds.marketwatch.com/marketwatch/topstories/"
      ]
    elsif t == "Games"
      return [
        "http://feeds.ign.com/ign/games-all",
        "http://store.steampowered.com/feeds/news.xml",
        "http://www.gamespot.com/feeds/mashup/"
      ]
    elsif t == "Science"
      return [
        "http://feeds.sciencedaily.com/sciencedaily",
        "http://feeds.nationalgeographic.com/ng/News/News_Main",
        "http://phys.org/rss-feed/breaking/",
      ]
    elsif t == "Architecture"
      return [
        "http://feeds.feedburner.com/ArchDaily",
        "http://www.dwell.com/articles/feed",
        "http://www.architecturaldigest.com/feed/rss/archdigest.rss.xml",
      ]
    elsif t == "Television"
      return [
        "http://feeds.eonline.com/eonline/topstories",
        "http://news.yahoo.com/rss/tv",
        "http://rss.tvguide.com/breakingnews",
      ]
    elsif t == "Photography"
      return [
        "http://feed.500px.com/500px-best",
        "http://feeds.feedburner.com/DigitalPhotographySchool",
        "http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/",
      ]
    elsif t == "Music"
      return [
        "http://www.rollingstone.com/music.rss",
        "http://www.billboard.com/rss/the-feed",
        "http://www.mtv.com/news/feed/",
      ]
    elsif t == "Movies"
      return [
        "http://feeds.ign.com/ign/movies-all",
        "http://www.rottentomatoes.com/syndication/rss/top_news.xml",
        "https://www.yahoo.com/movies/rss"
      ]
    elsif t == "Comics"
      return [
        "http://xkcd.com/rss.xml",
        "http://feeds.feedburner.com/uclick/calvinandhobbes",
        "http://www.questionablecontent.net/QCRSS.xml",
      ]
    elsif t == "Health"
      return [
        "http://rssfeeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC",
        "http://www.drugs.com/feeds/medical_news.xml",
        "http://www.medicinenet.com/rss/dailyhealth.xml",
      ]
    elsif t == "Sports"
      return [
        "http://sports-ak.espn.go.com/espn/rss/news",
        "http://www.nba.com/rss/nba_rss.xml",
        "http://www.goal.com/en/feeds/news?fmt=rss&ICID=HP",
      ]
    else
      return []
    end
  end

  def safari?
    if browser.safari?
      return "safari"
    else
      return ""
    end
  end

end
