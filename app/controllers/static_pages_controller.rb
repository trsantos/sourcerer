class StaticPagesController < ApplicationController
  def home
    if logged_in? && params[:from_next]
      redirect_to next_path
    end
  end

  def about
  end
end
