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
    url
  end
end
