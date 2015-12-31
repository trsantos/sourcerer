class StaticPagesController < ApplicationController
  def home
    redirect_to river_path if logged_in?
  end

  # maybe require login here?
  def feedback
  end
end
