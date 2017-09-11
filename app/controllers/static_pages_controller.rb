class StaticPagesController < ApplicationController
  def home
    redirect_to current_user.next_feed if logged_in?
  end

  def feedback
    redirect_to root_url unless logged_in?
  end
end
