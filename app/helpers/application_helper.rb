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
        'http://www.economist.com/feeds/print-sections/77/business.xml',
        'http://www.wsj.com/xml/rss/3_7014.xml',
        'http://www.forbes.com/business/feed2/',
        'http://www.ft.com/rss/home/us',
        'http://feeds.harvardbusiness.org/harvardbusiness/'
      ]
    elsif t == 'Design'
      return [
        'https://feeds.feedburner.com/Wallpaperfeed',
        'http://feeds.feedburner.com/design-milk',
        'http://feeds.feedburner.com/fastcodesign/feed',
        'http://www.designboom.com/feed/',
        'http://feeds.feedburner.com/FreshInspirationForYourHome/'
      ]
    elsif t == 'Gaming'
      return [
        'http://www.gamespot.com/feeds/mashup/',
        'https://www.gameinformer.com/feeds/thefeedrss.aspx',
        'http://www.pcgamer.com/feed/',
        'http://feeds.gawker.com/kotaku/full',
        'http://www.polygon.com/rss/index.xml'
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
        'http://www.mtv.com/news/music/feed/',
        'http://www.rollingstone.com/music.rss',
        'http://www.billboard.com/articles/rss.xml',
        'http://pitchfork.com/rss/news/',
        'http://www.nme.com/rss/news/music'
      ]
    elsif t == 'News'
      return [
        'http://rss.cnn.com/rss/edition.rss',
        'http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml',
        'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
        'http://www.theguardian.com/international/rss',
        'http://feeds.feedburner.com/foxnews/latest'
      ]
    elsif t == 'Photography'
      return [
        'http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/',
        'http://feed.500px.com/500px-best',
        'http://www.bostonglobe.com/rss/bigpicture',
        'http://feeds.feedburner.com/lomographic-society-international-atom',
        'http://feeds.feedburner.com/DigitalPhotographySchool'
      ]
    elsif t == 'Science'
      return [
        'http://news.nationalgeographic.com/index.rss',
        'http://syndication.howstuffworks.com/rss/science',
        'http://www.livescience.com/home/feed/site.xml',
        'http://feeds.sciencedaily.com/sciencedaily/top_news/top_science',
        'http://rss.sciam.com/ScientificAmerican-Global'
      ]
    elsif t == 'Sports'
      return [
        'http://sports.espn.go.com/espn/rss/news',
        'http://bleacherreport.com/articles/feed',
        'http://www.goal.com/en/feeds/news?fmt=rss&ICID=HP',
        'http://feeds.bbci.co.uk/sport/0/rss.xml',
        'http://feeds.gawker.com/deadspin/full'
      ]
    elsif t == 'Technology'
      return [
        'http://www.cnet.com/rss/all/',
        'http://www.engadget.com/rss.xml',
        'http://feeds.gawker.com/gizmodo/full',
        'http://techcrunch.com/feed/',
        'http://www.wired.com/feed/'
      ]
    else
      return []
    end
  end
end
