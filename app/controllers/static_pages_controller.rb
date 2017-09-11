class StaticPagesController < ApplicationController
  def home
    return unless logged_in?
    cookies[:check_for_updated_subs] = true
    redirect_to current_user.next_feed
  end

  def feedback
    redirect_to root_url unless logged_in?
  end
end
