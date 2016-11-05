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
    uri.scheme + '://' + uri.host + '/favicon.ico'
  rescue
    image_path 'feed-icon.png'
  end

  def show_payment_aside?
    @user.feeds.count > Payment.feed_limit &&
      Time.current > @user.expiration_date - Payment.trial_duration
  end
end
