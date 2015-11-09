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

  def in_auth?
    (params[:controller] == 'users' && params[:action] == 'new') ||
      (params[:controller] == 'sessions' && params[:action] == 'new')
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
    if t == 'Business'
      return [
        'http://www.forbes.com/business/feed2/',
        'https://feeds2.feedburner.com/businessinsider',
        'http://www.wsj.com/xml/rss/3_7014.xml',
        'http://www.entrepreneur.com/latest.rss',
        'http://www.ft.com/rss/home/us'
      ]
    elsif t == 'Design'
      return [
        'https://feeds.feedburner.com/Archdaily',
        'https://feeds.feedburner.com/fastcodesign/feed',
        'http://www.designboom.com/feed/',
        'http://feeds.feedburner.com/FreshInspirationForYourHome/',
        'http://feeds.feedburner.com/dezeen'
      ]
    elsif t == 'Gaming'
      return [
        'http://feeds.gawker.com/kotaku/full',
        'http://www.polygon.com/rss/index.xml',
        'http://www.eurogamer.net/?format=rss',
        'https://feeds.feedburner.com/RockPaperShotgun',
        'https://www.gameinformer.com/feeds/thefeedrss.aspx'
      ]
    elsif t == 'Movies'
      return [
        'https://feeds.feedburner.com/thr/news',
        'https://variety.com/v/film/feed/',
        'http://www.avclub.com/feed/rss/?tags=film',
        'https://deadline.com/v/film/feed/',
        'http://www.thewrap.com/category/movies/feed/'
      ]
    elsif t == 'Music'
      return [
        'http://www.rollingstone.com/music.rss',
        'http://www.mtv.com/news/music/feed/',
        'http://www.billboard.com/articles/rss.xml',
        'http://pitchfork.com/rss/news/',
        'http://www.nme.com/rss/news/music'
      ]
    elsif t == 'News'
      return [
        'http://rss.cnn.com/rss/edition.rss',
        'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
        'http://feeds.bbci.co.uk/news/rss.xml?edition=int',
        'http://rssfeeds.usatoday.com/usatoday-newstopstories',
        'http://online.wsj.com/xml/rss/3_8068.xml'
      ]
    elsif t == 'Photography'
      return [
        'http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/',
        'https://iso.500px.com/feed',
        'https://feeds.feedburner.com/PetaPixel',
        'http://digital-photography-school.com/feed/',
        'http://www.digitalcameraworld.com/feed/'
      ]
    elsif t == 'Science'
      return [
        'https://www.nasa.gov/rss/dyn/breaking_news.rss',
        'http://news.nationalgeographic.com/rss/index.rss',
        'http://feeds.nature.com/news/rss/news',
        'http://www.livescience.com/home/feed/site.xml',
        'https://feeds.feedburner.com/DiscoveryNews-Top-Stories'
      ]
    elsif t == 'Sports'
      return [
        'http://sports.espn.go.com/espn/rss/news',
        'http://feeds.bbci.co.uk/sport/0/rss.xml',
        'http://bleacherreport.com/articles/feed',
        'http://feeds.gawker.com/deadspin/full',
        'http://www.si.com/rss/si_topstories.rss'
      ]
    elsif t == 'Technology'
      return [
        'http://www.cnet.com/rss/all/',
        'http://www.engadget.com/rss.xml',
        'http://feeds.gawker.com/gizmodo/full',
        'https://www.theverge.com/rss/frontpage',
        'http://techcrunch.com/feed/'
      ]
    else
      return []
    end
  end
end
