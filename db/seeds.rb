Feed.update_all top_site: false

def insert_top_sites(urls)
  urls.each do |url|
    Feed.find_or_create_by(feed_url: url).update_attribute(:top_site, true)
  end
end

top_sites = [
  'http://news.yahoo.com/rss/',
  'https://en.wikipedia.org/w/api.php?action=featuredfeed&feed=featured&feedformat=atom',
  'https://www.reddit.com/.rss',
  'http://blog.instagram.com/rss',
  'http://feeds.feedburner.com/ImgurGallery?format=xml',
  'http://www.espn.com/espn/rss/news',
  'http://rss.msn.com/en-us/',
  'http://rss.cnn.com/rss/edition.rss',
  'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
  'http://www.huffingtonpost.com/feeds/index.xml',
  'https://discover.wordpress.com/feed/',
  'http://feeds.washingtonpost.com/rss/homepage',
  'http://www.aol.com/amp-proxy/api/v1/rss.xml',
  'http://feeds.feedburner.com/foxnews/latest',
  'http://www.buzzfeed.com/index.xml',
  'http://fandom.wikia.com/feed',
  'http://conservativetribune.com/feed/',
  'http://rssfeeds.usatoday.com/usatoday-newstopstories&x=1',
  'http://www.cnet.com/rss/all/',
  'http://www.forbes.com/real-time/feed2/',
  'http://www.nfl.com/rss/rsslanding?searchString=home',
  'http://www.dailymail.co.uk/home/index.rss',
  'http://feeds.bbci.co.uk/news/rss.xml',
  'https://vimeo.com/channels/staffpicks/videos/rss',
  'http://www.vice.com/rss',
  'http://backend.deviantart.com/rss.xml',
  'http://www.westernjournalism.com/feed/',
  'http://fivethirtyeight.com/all/feed',
  'http://www.politico.com/rss/politicopicks.xml',
  'http://feeds.feedburner.com/realclearpolitics/qlMj'
]

insert_top_sites top_sites
