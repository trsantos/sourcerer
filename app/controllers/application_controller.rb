class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  private

  def log_in(user, remember_me = false)
    if remember_me
      cookies.permanent[:auth_token] = user.auth_token
    else
      cookies[:auth_token] = user.auth_token
    end
  end

  def log_out
    cookies.delete :auth_token
    @current_user = nil
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:alert] = 'Please log in.'
    redirect_to login_url
  end

  def current_user
    @current_user ||=
      User.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token]
  end

  def logged_in?
    current_user.present?
  end

  def require_no_authentication
    redirect_to root_url if logged_in?
  end

  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete :forwarding_url
  end
end
