module ApplicationHelper
  def full_title(page_title = '')
    base_title = 'Sourcerer'
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def in_feeds_show
    params[:controller] == 'feeds' && params[:action] == 'show'
  end

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?
    store_location
    flash[:alert] = 'Please log in.'
    redirect_to login_url
  end

  def process_url(url)
    return nil if url.blank?
    url = url.strip
    unless url.start_with?('http:') || url.start_with?('https:')
      url = 'http://' + url
    end
    url
  end

  def get_feeds(topic)
    t = topic.name
    if t == "Technology"
      return [
        # Alexa categories: Computers, Home/Consumer Information
        #"http://www.techmeme.com/feed.xml", # 12,553
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
        "http://feeds.arstechnica.com/arstechnica/index/" # 1,238
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
        #"http://www.entrepreneur.com/latest.rss", # 770
        #"http://www.investing.com/rss/news.rss", # 1,045
        "http://www.ft.com/rss/home/uk", # 1,379
        #"http://feeds.inc.com/home/updates", # 1,101
        #"http://rss.cnn.com/fortunefinance", # 1,623
        "http://www.economist.com/sections/business-finance/rss.xml", # 1,613
        #"http://www.ibtimes.com/rss/companies", # 1,452
        "http://feeds.harvardbusiness.org/harvardbusiness/"
      ]
    elsif t == "Games"
      return [
        "http://feeds.ign.com/ign/all", # 282
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
        #"https://www.youtube.com/feeds/videos.xml?channel_id=UCAuUUnT6oDeKwE6v1NGQxug", # 736
        "http://feeds.nationalgeographic.com/ng/News/News_Main", # 1,039
        "http://feeds.nature.com/NatureNewsComment", # 1,738
        #"http://feeds.feedburner.com/IeeeSpectrumFullText", # 1,957
        #"http://www.livescience.com/home/feed/site.xml", # 2,667
        "http://feeds.sciencedaily.com/sciencedaily/", # 2,687
        "http://rss.sciam.com/ScientificAmerican-Global", # 4,167
        "http://www.space.com/home/feed/site.xml", # 4,716
        #"http://news.sciencemag.org/rss/current.xml", # 5,190
        #"http://phys.org/rss-feed/breaking/", # 5,202
      ]
    elsif t == "Architecture"
      return [
        "http://feeds.feedburner.com/ArchDaily", # 2,717
        "http://feeds.feedburner.com/dezeen", # 11,217
        "http://www.dwell.com/articles/feed", # 20,741
        "http://www.architecturaldigest.com/feed/rss/architecture-design.rss.xml", # 17,454
        "http://architizer.com/blog/feed/", # 25,715
        #"http://archinect.com/feed/0/features", # 32,524
      ]
    # elsif t == "Television"
    #   return [
    #     #"http://feeds.ign.com/ign/tv-all",
    #     #"http://feeds.eonline.com/eonline/topstories", # 563
    #     "http://morningafter.gawker.com/rss",
    #     "http://www.rollingstone.com/tv.rss",
    #     "http://feeds.feedburner.com/thr/television",
    #     "http://rss.tvguide.com/breakingnews", # 1,395
    #     #"http://www.avclub.com/feed/rss/?feature_types=tv-club",
    #     "http://variety.com/feed/",
    #     #"http://news.yahoo.com/rss/tv",
    #     #"http://tvline.com/feed/", # 3,617
    #   ]
    elsif t == "Music"
      return [
        "http://www.rollingstone.com/music.rss",
        "http://www.mtv.com/news/feed/",
        "http://www.billboard.com/articles/rss.xml",
        "http://pitchfork.com/rss/news/",
        #"http://www.allmusic.com/rss",
        "http://www.nme.com/rss/news"
      ]
    elsif t == "Movies"
      return [
        #"http://feeds.ign.com/ign/movies-all", # 281
        "http://defamer.gawker.com/rss", # 620
        #"http://www.rollingstone.com/movies.rss", # 1,227
        "http://feeds.feedburner.com/thr/film", # 1,232
        "http://www.avclub.com/feed/rss/?tags=film", # 1,727
        #"http://www.boxofficemojo.com/data/rss.php?file=topstories.xml", # 2,581
        #"http://whatculture.com/category/film/feed", # 2,737
        "http://www.theguardian.com/film/rss",
        "http://rss.feedsportal.com/c/592/f/7507/index.rss" # Empire
      ]
    elsif t == "Photography"
      return [
        "http://flickr.tumblr.com/rss", # 135
        "http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/", # 1,039
        "http://feed.500px.com/500px-best", # 1,557
        "http://www.bostonglobe.com/rss/bigpicture", # 2,838
        "http://feeds.feedburner.com/DigitalPhotographySchool", # 5,903
        #"http://feeds2.feedburner.com/photographyblog", # 15,315
        #"http://feeds.feedburner.com/Ephotozine", # 18,027
      ]
    # elsif t == "Comics"
    #   return [
    #     "http://xkcd.com/rss.xml", # 1,502
    #     "http://feeds.feedburner.com/uclick/calvinandhobbes", #2,473
    #     #"http://feeds.feedburner.com/Explosm", # 2,464
    #     "http://www.comicbookresources.com/feed.php?feed=all", # 3,650
    #     #"http://www.questionablecontent.net/QCRSS.xml", # 3,826
    #     "http://www.smbc-comics.com/rss.php", # 4,042
    #     "http://dilbert.com/feed", # 4,792
    #   ]
    # elsif t == "Health" # Maybe I should axe this topic. Not many good feeds
    #   return [
    #     "http://rssfeeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC", # 300
    #     "http://feeds.health.com/healthtopstories",
    #     "http://www.medscape.com/cx/rssfeeds/2700.xml", # 2,220
    #     "https://www.psychologytoday.com/front/feed", # 2,451
    #     "https://www.yahoo.com/health/rss",
    #     #"http://www.menshealth.com/events-promotions/washpofeed", # 3,230
    #     #"http://www.womenshealthmag.com/washpofeed", # 3,653
    #   ]
    elsif t == "Sports"
      return [
        "http://sports.espn.go.com/espn/rss/news", # 102
        "http://bleacherreport.com/articles/feed", # 343
        "http://www.goal.com/en/feeds/news?fmt=rss&ICID=HP", # 433
        "http://www.nba.com/rss/nba_rss.xml", # 403
        "http://feeds.bbci.co.uk/sport/0/rss.xml",
        #"http://www.cbssports.com/partners/feeds/rss/home_news", # 491
        #"http://feeds.gawker.com/deadspin/full", # 955
        #"http://api.foxsports.com/v1/rss?partnerKey=zBaFxRyGKCfxBagJG9b8pqLyndmvo7UU",
        #"http://www.fifa.com/rss/index.xml",
      ]
    else
      return []
    end
  end
end
