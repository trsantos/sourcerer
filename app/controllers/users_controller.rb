class UsersController < ApplicationController
  before_action :require_no_authentication, only: [:new, :create]
  before_action :logged_in_user, except: [:new, :create]
  before_action :correct_user,   only: [:show, :edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    flash[:success] = 'Profile updated.' if @user.update_attributes(user_params)
    render 'edit'
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:primary] = 'User deleted succesfully.'
    redirect_to root_url
  end

  def follow_top_sites
    user = current_user
    top_sites.shuffle.each do |s|
      user.subscriptions.find_or_create_by(feed: Feed.find_or_create_by(feed_url: s))
    end
    flash[:primary] = 'Ok, done! Happy reading.'
    redirect_to user.next_feed
  end

  private

  def user_params
    params
      .require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user == @user
  end

  def top_sites
    [
      'http://news.yahoo.com/rss/',
      'https://en.wikipedia.org/w/api.php?action=featuredfeed&feed=featured&feedformat=atom',
      'https://www.reddit.com/.rss',
      'http://feeds.feedburner.com/ImgurGallery?format=xml',
      'http://rss.cnn.com/rss/edition.rss',
      'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
      'http://rss.msn.com/en-us/',
      'http://sports.espn.go.com/espn/rss/news',
      'http://www.huffingtonpost.com/feeds/news.xml',
      'https://discover.wordpress.com/feed/',
      'http://www.buzzfeed.com/index.xml',
      'http://www.aol.com/amp-proxy/api/v1/rss.xml',
      'http://feeds.washingtonpost.com/rss/homepage',
      'http://feeds.feedburner.com/foxnews/latest',
      'http://fandom.wikia.com/feed',
      'http://rssfeeds.usatoday.com/usatoday-NewsTopStories',
      'http://www.forbes.com/real-time/feed2/',
      'http://www.cnet.com/rss/all/',
      'http://www.vice.com/rss',
      'http://www.dailymail.co.uk/home/index.rss',
      'http://patch.com/feeds',
      'http://conservativetribune.com/feed/',
      'http://feeds2.feedburner.com/businessinsider',
      'http://rssfeeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC',
      'http://feeds.bbci.co.uk/news/rss.xml',
      'http://www.worldlifestyle.com/feed',
      'http://feeds.gawker.com/gizmodo/full',
      'http://bleacherreport.com/articles/feed',
      'http://feeds.nbcnews.com/feeds/topstories',
      'http://www.theguardian.com/international/rss',
      'https://flickr.tumblr.com/rss',
      'http://www.wsj.com/xml/rss/3_7014.xml',
      'http://feeds.abcnews.com/abcnews/topstories',
      'http://www.npr.org/rss/rss.php?id=1001',
      'http://feeds.feedburner.com/DrudgeReportFeed',
      'https://vimeo.com/channels/staffpicks/videos/rss',
      'http://www.nfl.com/rss/rsslanding?searchString=home',
      'http://www.cbsnews.com/latest/rss/main',
      'http://feeds.people.com/people/headlines',
      'http://feeds.gawker.com/lifehacker/full'
    ]
  end
end
