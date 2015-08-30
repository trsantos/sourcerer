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
    if t == 'Business'
      # change Economist to FT?
      return [
        'http://www.forbes.com/business/feed2/',
        'http://www.wsj.com/xml/rss/3_7014.xml',
        'http://rss.cnn.com/rss/money_topstories.rss',
        'http://www.entrepreneur.com/latest.rss',
        'http://www.ft.com/rss/home/us'
      ]
    elsif t == 'Design'
      return [
        'http://feeds.feedburner.com/fastcodesign/feed',
        'http://www.designboom.com/feed/',
        'http://feeds.feedburner.com/FreshInspirationForYourHome/',
        'http://feeds.feedburner.com/dezeen',
        'http://feeds.feedburner.com/design-milk'
      ]
    elsif t == 'Gaming'
      return [
        'http://feeds.ign.com/ign/all',
        'http://feeds.gawker.com/kotaku/full',
        'http://www.polygon.com/rss/index.xml',
        'http://www.eurogamer.net/?format=rss',
        'http://feeds.feedburner.com/RockPaperShotgun'
      ]
    elsif t == 'Movies'
      return [
        'http://feeds.feedburner.com/thr/film',
        'http://www.avclub.com/feed/rss/?tags=film',
        'http://rss.feedsportal.com/c/592/f/7507/index.rss'
      ]
    elsif t == 'Music'
      return [
        'http://www.rollingstone.com/music.rss',
        'http://www.billboard.com/articles/rss.xml',
        'http://www.nme.com/rss/news'
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
        'http://www.goal.com/en/feeds/news?fmt=rss&ICID=HP',
        'http://feeds.bbci.co.uk/sport/0/rss.xml'
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
