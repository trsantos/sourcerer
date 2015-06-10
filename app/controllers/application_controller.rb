class ApplicationController < ActionController::Base
  require 'open-uri'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  before_filter :authorize

  private

  def authorize
    if current_user.admin?
      Rack::MiniProfiler.authorize_request
    end
  end

end
