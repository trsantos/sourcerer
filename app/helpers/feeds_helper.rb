module FeedsHelper
  
  def sub_title(feed)
    if logged_in?
      sub = current_user.subscriptions.find_by(feed_id: feed.id)
      if sub and !sub.title.blank?
        return sub.title
      end
    end
    return feed.title
  end

  def sub_url(feed)
    if logged_in?
      sub = current_user.subscriptions.find_by(feed_id: feed.id)
      if sub and !sub.site_url.blank?
        return sub.site_url
      end
    end
    return feed.site_url
  end

  def get_favicon(url)
    return "http://www.google.com/s2/favicons?domain=" + url

    # Maybe I shouldn't depend on Google here...
    favicon_url = url + "favicon.ico"
    f =  URI.parse(favicon_url)
    if Net::HTTP.new(f.host, f.port).request_head(f.path).code == "200"
      f.to_s
    else
      "http://www.google.com/s2/favicons?domain=" + url
    end
  end
  
end
