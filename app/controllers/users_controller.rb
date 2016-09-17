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
    if @user.update_attributes(user_params)
      flash.now[:success] = 'Profile updated.'
    end
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
      user
        .subscriptions
        .find_or_create_by(feed: Feed.find_or_create_by(feed_url: s))
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

  # TODO: Move this into the DB. Should not be part of the controller
  def top_sites
    [
      'http://news.yahoo.com/rss/',
      'https://en.wikipedia.org/w/api.php?action=featuredfeed&feed=featured&feedformat=atom',
      'https://www.reddit.com/.rss',
      'http://blog.instagram.com/rss',
      'http://feeds.feedburner.com/ImgurGallery?format=xml',
      'http://www.espn.com/espn/rss/news',
      'http://rss.msn.com/en-us/',
      'http://rss.cnn.com/rss/edition.rss',
      'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
      'http://www.huffingtonpost.com/feeds/index.xml', # 10
      'https://discover.wordpress.com/feed/',
      'http://feeds.washingtonpost.com/rss/homepage',
      'http://www.aol.com/amp-proxy/api/v1/rss.xml',
      'http://feeds.feedburner.com/foxnews/latest',
      'http://www.buzzfeed.com/index.xml',
      'http://fandom.wikia.com/feed',
      'http://conservativetribune.com/feed/',
      'http://rssfeeds.usatoday.com/usatoday-newstopstories&x=1',
      'http://www.cnet.com/rss/all/',
      'http://www.forbes.com/real-time/feed2/', # 20
      'http://www.nfl.com/rss/rsslanding?searchString=home',
      'http://www.dailymail.co.uk/home/index.rss',
      'http://feeds.bbci.co.uk/news/rss.xml',
      'https://vimeo.com/channels/staffpicks/videos/rss',
      'http://www.vice.com/rss',
      'http://scribol.com/feed/',
      'http://detonate.com/feed/',
      'http://www.worldlifestyle.com/feed',
      'http://www.cbssports.com/partners/feeds/rss/home_news',
      'http://feeds.feedburner.com/DrudgeReportFeed', # 30
      'http://patch.com/feeds',
      'http://bleacherreport.com/articles/feed',
      'http://rssfeeds.webmd.com/rss/rss.aspx?RSSSource=RSS_PUBLIC',
      'http://www.wsj.com/xml/rss/3_7014.xml',
      'http://backend.deviantart.com/rss.xml',
      'http://feeds.gawker.com/gizmodo/full',
      'http://feeds.nbcnews.com/feeds/topstories',
      'http://www.westernjournalism.com/feed/',
      'http://www.theguardian.com/international/rss',
      'http://www.npr.org/rss/rss.php?id=1001' # 40
    ]
  end
end
