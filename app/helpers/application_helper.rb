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
    if params[:controller] == "feeds" && params[:action] == "show"
      base + " show-for-medium-up header-in-feeds-controller"
    else
      base
    end
  end

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:alert] = "Please log in."
      redirect_to login_url
    end
  end
end
