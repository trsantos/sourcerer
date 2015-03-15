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
    elsif t == "Architecture"
      return [
        "http://feeds.feedburner.com/ArchDaily",
        "http://www.dwell.com/articles/feed",
        "http://www.architecturaldigest.com/feed/rss/archdigest.rss.xml",
        "http://archinect.com/feed/home",
        "http://www.domusweb.it/bin/domusweb/rss?country=en"
      ]
    elsif t == "Television"
      return [
        "http://feeds.eonline.com/eonline/topstories",
        "http://news.yahoo.com/rss/tv",
        "http://rss.tvguide.com/breakingnews",
        "http://www.tv.com/news/news.xml",
        "http://www.tvfanatic.com/rss.xml"
      ]
    elsif t == "Photography"
      return [
        "https://api.flickr.com/services/feeds/photos_public.gne",
        "http://feed.500px.com/500px-best",
        "http://feeds.feedburner.com/DigitalPhotographySchool",
        "http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/",
        "http://feeds2.feedburner.com/photographyblog"
      ]
    elsif t == "Music"
      return [
        "http://www.rollingstone.com/music.rss",
        "http://www.billboard.com/rss/the-feed",
        "http://www.mtv.com/news/feed/",
        "http://www.allmusic.com/rss",
        "http://www.stereogum.com/feed/"
      ]
    elsif t == "Movies"
      return [
        "http://feeds.ign.com/ign/movies-all",
        "http://www.rottentomatoes.com/syndication/rss/top_news.xml",
        "http://whatculture.com/feed",
        "http://boxofficemojo.com/data/rss.php?file=topstories.xml",
        "https://www.yahoo.com/movies/rss"
      ]
    elsif t == "Comics"
      return [
        "http://xkcd.com/rss.xml",
        "http://feeds.feedburner.com/uclick/calvinandhobbes",
        "http://www.questionablecontent.net/QCRSS.xml",
        "http://www.penny-arcade.com/rss.xml",
        "http://www.comicbookresources.com/feed.php?feed=all"
      ]
    elsif t == "Health"
      return [
        "http://rssfeeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC",
        "http://www.drugs.com/feeds/medical_news.xml",
        "http://www.medicinenet.com/rss/dailyhealth.xml",
        "http://feeds.health.com/healthtopstories",
        "http://articles.mercola.com/sites/articles/rss.aspx"
      ]
    elsif t == "Sports"
      return [
        "http://sports-ak.espn.go.com/espn/rss/news",
        "http://bleacherreport.com/articles/feed",
        "http://www.nba.com/rss/nba_rss.xml",
        "http://www.goal.com/en/feeds/news?fmt=rss&ICID=HP",
        "http://www.nfl.com/rss/rsslanding?searchString=home"
      ]
    else
      return []
    end
  end
end
