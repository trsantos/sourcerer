class ApplicationController < ActionController::Base
  require 'open-uri'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  def authorize
    if current_user.is_admin?
      Rack::MiniProfiler.authorize_request
    end
  end
end
