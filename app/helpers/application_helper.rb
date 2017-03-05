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

  def process_url(url)
    return nil if url.blank?
    url = url.strip
    url = 'http://' + url unless url.start_with?('http:', 'https:')
    if url.include?('youtube.com/user') || url.include?('youtube.com/channel')
      get_youtube_feed url
    else
      url
    end
  end

  def get_youtube_feed(url)
    require 'open-uri'
    doc = Nokogiri::HTML(open(url))
    id = doc.css("meta[itemprop='channelId']").first.attributes['content'].value
    'https://www.youtube.com/feeds/videos.xml?channel_id=' + id
  rescue
    url
  end
end
