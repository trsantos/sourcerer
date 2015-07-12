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

  def favicon_for(url)
    begin
      uri = URI.parse url
      return '//' + uri.host + '/favicon.ico'
    rescue
      return ""
    end
  end
  
end
