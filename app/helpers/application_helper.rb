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
    return params[:controller] == "feeds" && params[:action] == "show"
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
    if t == "Computers & Internet"
      return [
        # Alexa categories: Computers, Home/Consumer Information
        "http://www.techmeme.com/feed.xml", # 12,553
        "http://www.cnet.com/rss/all/", # 149
        #"http://feeds.mashable.com/Mashable", # 287
        "http://www.engadget.com/rss.xml", # 312
        #"http://www.gsmarena.com/rss-news-reviews.php3", # 364
        #"http://feeds.gawker.com/lifehacker/full", # 366
        #"http://feeds.gawker.com/gizmodo/full", # 404
        "http://techcrunch.com/feed/", # 444
        #"http://www.theverge.com/rss/frontpage", # 458
        #"http://feeds2.feedburner.com/ziffdavis/pcmag", # 722
        "http://www.wired.com/feed/", # 666
        #"http://www.tomshardware.com/feeds/rss2/news.xml", # 796
        #"http://feeds2.feedburner.com/techradar/allnews", # 929
        #"http://feeds.howtogeek.com/howtogeek", # 936
        #"http://feeds.arstechnica.com/arstechnica/index/" # 1,238
      ]
    elsif t == "News"
      return [
        "http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml", # 74
        "http://rss.cnn.com/rss/edition.rss", # 86
        #"http://www.huffingtonpost.com/feeds/index.xml", # 109
        "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml", # 110
        #"http://news.google.com/?output=rss",
        "http://www.theguardian.com/international/rss", # 157
        #"http://www.forbes.com/real-time/feed2/", # 169
        #"http://feeds.feedburner.com/foxnews/latest", # 212
        "http://feeds.washingtonpost.com/rss/homepage", # 224
        #"http://www.wsj.com/xml/rss/3_7014.xml", # 319
        #"http://rssfeeds.usatoday.com/usatoday-NewsTopStories", # 326
        #"http://feeds.reuters.com/reuters/topNews" # 409
      ]
    elsif t == "Business"
      return [
        "http://www.forbes.com/business/feed2/", # 169
        "http://www.wsj.com/xml/rss/3_7014.xml", # 319
        #"http://feeds.reuters.com/reuters/businessNews", # 411
        #"http://rss.cnn.com/rss/money_topstories.rss", # 86
        #"http://feeds.marketwatch.com/marketwatch/topstories/", # 762
        "http://www.entrepreneur.com/latest.rss", # 770
        #"http://www.investing.com/rss/news.rss", # 1,045
        "http://www.ft.com/rss/home/uk", # 1,379
        #"http://feeds.inc.com/home/updates", # 1,101
        #"http://rss.cnn.com/fortunefinance", # 1,623
        "http://www.economist.com/sections/business-finance/rss.xml", # 1,613
        #"http://www.ibtimes.com/rss/companies", # 1,452
      ]
    elsif t == "Games"
      return [
        "http://feeds.ign.com/ign/games-all", # 282
        #"http://store.steampowered.com/feeds/news.xml", # 280
        "http://feeds.gawker.com/kotaku/full", # 758
        "http://www.gamespot.com/feeds/mashup/", # 860
        "http://www.pcgamer.com/feed/", # 1,665
        "http://www.polygon.com/rss/index.xml", # 2,211
        #"http://www.eurogamer.net/?format=rss", # 4,193
        #"http://www.vg247.com/feed/", # 4,801
        #"http://www.gamesradar.com/all-platforms/news/rss/", # 4,280
        #"http://www.gameinformer.com/feeds/topfiverss.aspx?p=home", # 6,551
        #"http://www.gametrailers.com/reviews/feed", # 9,873
      ]
    elsif t == "Science"
      return [
        "https://www.youtube.com/feeds/videos.xml?channel_id=UCAuUUnT6oDeKwE6v1NGQxug", # 736
        "http://feeds.nationalgeographic.com/ng/News/News_Main", # 1,039
        "http://feeds.nature.com/NatureNewsComment", # 1,738
        "http://feeds.feedburner.com/IeeeSpectrumFullText", # 1,957
        "http://www.livescience.com/home/feed/site.xml", # 2,667
        "http://feeds.sciencedaily.com/sciencedaily/", # 2,687
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
