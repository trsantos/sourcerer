module FeedsHelper
  def sub_title(feed)
    if @subscription
      @subscription.title || feed.title
    else
      feed.title
    end
  end

  def sub_url(feed)
    if @subscription
      @subscription.site_url || feed.site_url
    else
      feed.site_url
    end
  end

  def favicon_for(url)
    uri = URI.parse url
    return 'dummy' if (uri.host == 'www.pcgamer.com') || (uri.host == 'www.maximumpc.com')
    return uri.scheme + '://' + uri.host + '/favicon.ico'
  rescue
    return ''
  end

  def google_favicon(feed)
    base = 'http://www.google.com/s2/favicons?domain='
    begin
      return base + URI.parse(feed.site_url).host
    rescue
      return base + (feed.site_url || feed.feed_url)
    end
  end
end
