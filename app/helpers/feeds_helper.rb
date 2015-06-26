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
    default = feed.site_url || ""
    sub = current_user.subscriptions.find_by(feed_id: feed.id)
    if sub
      return sub.site_url || default
    else
      return default
    end
  end

  def get_favicon(url)
    return "http://www.google.com/s2/favicons?domain=" + url
  end

  def favicon_for(url)
    uri = URI.parse url
    return uri.scheme + '://' + uri.host + '/favicon.ico'
  end
  
end
