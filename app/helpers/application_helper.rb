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
    if t == 'Technology'
      return [
        # Alexa categories: Computers, Home/Consumer Information
        'http://www.cnet.com/rss/all/',
        'http://techcrunch.com/feed/',
        'http://www.wired.com/feed/'
      ]
    elsif t == 'News'
      return [
        'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
        'http://www.theguardian.com/international/rss',
        'http://newsrss.bbc.co.uk/rss/newsonline_world_edition/front_page/rss.xml'
      ]
    elsif t == 'Business'
      return [
        'http://www.wsj.com/xml/rss/3_7014.xml',
        'http://www.ft.com/rss/home/uk',
        'http://www.economist.com/sections/business-finance/rss.xml'
      ]
    elsif t == 'Games'
      return [
        'http://feeds.ign.com/ign/all',
        'http://www.gamespot.com/feeds/mashup/',
        'http://www.pcgamer.com/feed/'
      ]
    elsif t == 'Science'
      return [
        'http://feeds.nationalgeographic.com/ng/News/News_Main',
        'http://feeds.nature.com/NatureNewsComment',
        'http://feeds.sciencedaily.com/sciencedaily/'
      ]
    elsif t == 'Architecture'
      return [
        'http://feeds.feedburner.com/ArchDaily',
        'http://feeds.feedburner.com/dezeen',
        'http://www.dwell.com/articles/feed'
      ]
    elsif t == 'Music'
      return [
        'http://www.rollingstone.com/music.rss',
        'http://pitchfork.com/rss/news/',
        'http://www.nme.com/rss/news'
      ]
    elsif t == 'Movies'
      return [
        'http://feeds.feedburner.com/thr/film',
        'http://www.theguardian.com/film/rss',
        'http://rss.feedsportal.com/c/592/f/7507/index.rss'
      ]
    elsif t == 'Photography'
      return [
        'http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/',
        'http://feed.500px.com/500px-best',
        'http://feeds.feedburner.com/DigitalPhotographySchool'
      ]
    # elsif t == 'Comics'
    #   return [
    #     'http://xkcd.com/rss.xml',
    #     'http://feeds.feedburner.com/uclick/calvinandhobbes',
    #     'http://www.smbc-comics.com/rss.php'
    #   ]
    elsif t == 'Sports'
      return [
        'http://sports.espn.go.com/espn/rss/news',
        'http://www.goal.com/en/feeds/news?fmt=rss&ICID=HP',
        'http://feeds.bbci.co.uk/sport/0/rss.xml'
      ]
    else
      return []
    end
  end
end
