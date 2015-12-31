class StaticPagesController < ApplicationController
  def home
    redirect_to current_user.next_feed if logged_in?
  end

  # maybe require login here?
  def feedback
  end
end
