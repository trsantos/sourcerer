class SubscriptionsController < ApplicationController
  include ApplicationHelper
  include FeedsHelper

  before_action :logged_in_user
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    @subscriptions = current_user.subscriptions.includes(:feed)
                     .order(updated: :desc, starred: :desc)
  end

  def create
    @feed = Feed.find(params[:feed_id])
    @subscription = current_user.follow(@feed)
    if @subscription.updated?
      @subscription.update_attributes(visited_at: Time.zone.now, updated: false)
    end
    respond_to do |format|
      format.html { redirect_to @feed }
      format.js
    end
  end

  def edit
    @subscription = Subscription.find(params[:id])
  end

  def update
    set_update_params
    @subscription = Subscription.find(params[:id])
    @subscription.update_attributes(sub_params)
    @feed = @subscription.feed
    respond_to do |format|
      format.html { redirect_to @feed }
      format.js
    end
  end

  def destroy
    @feed = Subscription.find(params[:id]).feed
    current_user.unfollow(@feed)
    respond_to do |format|
      format.html { redirect_to @feed }
      format.js
    end
  end

  private

  def sub_params
    params.require(:subscription).permit(:title, :site_url, :starred)
  end

  def set_update_params
    set_update_title
    set_update_url
  end

  def set_update_title
    title = params[:subscription][:title]
    params[:subscription][:title] = nil if title && title.blank?
  end

  def set_update_url
    site_url = params[:subscription][:site_url]
    return if site_url.nil?
    params[:subscription][:site_url] = process_url site_url
  end

  def correct_user
    @user = User.find(Subscription.find(params[:id]).user_id)
    redirect_to root_url unless current_user?(@user) || current_user.admin?
  end
end
