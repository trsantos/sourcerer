class StaticPagesController < ApplicationController
  def home
    redirect_to next_path if logged_in?
  end
end
