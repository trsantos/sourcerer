module ApplicationHelper
  def full_title(page_title = '')
    base_title = 'Sourcerer'.freeze
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def in_feeds_show
    params[:controller] == 'feeds'.freeze && params[:action] == 'show'.freeze
  end

  def in_auth?
    (params[:controller] == 'users'.freeze &&
     params[:action] == 'new'.freeze) ||
      (params[:controller] == 'sessions'.freeze &&
       params[:action] == 'new'.freeze)
  end

  def process_url(url)
    return nil if url.blank?
    url = url.strip
    unless url.start_with?('http:'.freeze) || url.start_with?('https:'.freeze)
      url = 'http://'.freeze + url
    end
    url
  end
end
