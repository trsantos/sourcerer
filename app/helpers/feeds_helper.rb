module FeedsHelper
  def sub_title(feed)
    default = feed.title || "(Untitled | #{feed.id})"
    sub = current_user.subscriptions.find_by(feed_id: feed.id)
    if sub
      return sub.title || default
    else
      return default
    end
  end

  def sub_url(feed)
    default = feed.site_url || ''
    sub = current_user.subscriptions.find_by(feed_id: feed.id)
    if sub
      return sub.site_url || default
    else
      return default
    end
  end

  def favicon_for(url)
    uri = URI.parse url
    return 'dummy' if uri.host == 'www.pcgamer.com'
    return uri.scheme + '://' + uri.host + '/favicon.ico'
  rescue
    return ''
  end

  def google_favicon(feed)
    base = 'http://www.google.com/s2/favicons?domain='
    begin
      return base + URI.parse(feed.site_url).host
    rescue
      return base + feed.site_url
    end
  end
end
