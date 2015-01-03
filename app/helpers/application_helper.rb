module ApplicationHelper
  def full_title(page_title = '')
    base_title = "Reader"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def app_header_class
    base = "app-header"
    if params[:controller] == "feeds"
      base + " show-for-medium-up header-in-feeds-controller"
    else
      base
    end
  end
end
