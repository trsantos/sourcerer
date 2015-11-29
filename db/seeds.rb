# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def seed_topic(topic_name, urls)
  t = Topic.find_or_create_by(name: topic_name)
  t.feeds = urls.map { |url| Feed.find_or_create_by(feed_url: url) }
end

# Each topic should be disjoint from others

seed_topic 'Business',
           [
             'http://www.forbes.com/business/feed2/',
             'https://feeds2.feedburner.com/businessinsider',
             'http://www.wsj.com/xml/rss/3_7014.xml',
             'http://www.entrepreneur.com/latest.rss',
             'http://fortune.com/rss'
           ]

seed_topic 'Design',
           [
             'https://feeds.feedburner.com/Archdaily',
             'https://feeds.feedburner.com/fastcodesign/feed',
             'http://www.designboom.com/feed/',
             'http://feeds.feedburner.com/FreshInspirationForYourHome/',
             'http://feeds.feedburner.com/dezeen'
           ]

seed_topic 'Gaming',
           [
             'http://www.gamespot.com/feeds/mashup/',
             'http://feeds.gawker.com/kotaku/full',
             'http://www.pcgamer.com/feed/',
             'http://www.polygon.com/rss/index.xml',
             'http://www.gamesradar.com/all-platforms/news/rss/'
           ]

seed_topic 'Movies',
           [
             'https://feeds.feedburner.com/thr/news',
             'https://variety.com/v/film/feed/',
             'http://www.avclub.com/feed/rss/?tags=film',
             'https://deadline.com/v/film/feed/',
             'http://www.thewrap.com/category/movies/feed/'
           ]

seed_topic 'Music',
           [
             'http://www.rollingstone.com/music.rss',
             'http://www.mtv.com/news/music/feed/',
             'http://www.billboard.com/articles/rss.xml',
             'http://pitchfork.com/rss/news/',
             'http://www.nme.com/rss/news/music'
           ]

seed_topic 'News',
           [
             'http://rss.cnn.com/rss/edition.rss',
             'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml',
             'http://feeds.bbci.co.uk/news/rss.xml?edition=int',
             'http://www.huffingtonpost.com/feeds/index.xml',
             'http://www.theguardian.com/international/rss'
           ]

seed_topic 'Photography',
           [
             'http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/',
             'https://iso.500px.com/feed',
             'http://www.bostonglobe.com/rss/bigpicture',
             'https://feeds.feedburner.com/PetaPixel',
             'http://digital-photography-school.com/feed/'
           ]

seed_topic 'Science',
           [
             'https://www.nasa.gov/rss/dyn/breaking_news.rss',
             'http://news.nationalgeographic.com/rss/index.rss',
             'http://feeds.nature.com/news/rss/news',
             'http://www.livescience.com/home/feed/site.xml',
             'https://feeds.feedburner.com/DiscoveryNews-Top-Stories'
           ]

seed_topic 'Sports',
           [
             'http://sports.espn.go.com/espn/rss/news',
             'http://feeds.bbci.co.uk/sport/0/rss.xml',
             'http://www.nfl.com/rss/rsslanding?searchString=home',
             'http://bleacherreport.com/articles/feed',
             'http://www.goal.com/en/feeds/news?fmt=rss&ICID=HP'
           ]

seed_topic 'Technology',
           [
             'http://www.cnet.com/rss/all/',
             'http://www.engadget.com/rss.xml',
             'http://feeds.gawker.com/gizmodo/full',
             'https://www.theverge.com/rss/frontpage',
             'http://techcrunch.com/feed/'
           ]

Topic.all.each { |t| t.feeds.all.each(&:update) } if Rails.env.production?
