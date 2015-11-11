class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include ApplicationHelper
  include EntriesHelper

  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy
  has_many :cached_images, dependent: :destroy

  validates :feed_url, presence: true, uniqueness: true

  def self.entries_per_feed
    10
  end

  def update
    # return if entries.any? && updated_at > 2.hours.ago
    fj_feed = fetch_and_parse
    return if fj_feed.is_a? Integer
    if Rails.env.development?
      entries.delete_all
      cached_images.delete_all
    end
    update_feed_attributes fj_feed
    update_entries fj_feed
  end

  def only_images?
    feed_url.start_with? 'https://www.youtube.com/feeds/videos.xml?channel_id='
  end

  private

  def fetch_and_parse
    setup_fj
    return Feedjira::Feed.fetch_and_parse feed_url
  rescue
    0
  end

  def update_feed_attributes(fj_feed)
    update_attributes(title: fj_feed.title,
                      site_url: process_url(fj_feed.url || fj_feed.feed_url),
                      description: sanitize(strip_tags(fj_feed.description)),
                      logo: fj_feed.logo,
                      updated_at: Time.zone.now)
  end

  def update_entries(fj_feed)
    return unless new_entries? fj_feed
    entries.delete_all
    insert_new_entries fj_feed
    subscriptions.each do |s|
      s.update_attribute(:updated, true)
    end
  end

  def new_entries?(fj_feed)
    fj_entries = fj_feed.entries.first(3)
    fj_entries.each do |e|
      return true unless entries.find_by(url: e.url)
    end
    false
  end

  def insert_new_entries(fj_feed)
    fj_entries = fj_feed.entries.first(Feed.entries_per_feed).reverse
    fj_entries.each do |e|
      insert_entry e
    end
  end

  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element(:enclosure, value: :url, as: :image)
    Feedjira::Feed.add_common_feed_entry_element('media:thumbnail', value: :url, as: :image)
    Feedjira::Feed.add_common_feed_entry_element('media:content', value: :url, as: :image)
    Feedjira::Feed.add_common_feed_entry_element(:img, value: :scr, as: :image)
    Feedjira::Feed.add_common_feed_element(:url, as: :logo, ancestor: :image)
    Feedjira::Feed.add_common_feed_element(:logo, as: :logo)
  end

  def insert_entry(e)
    description = e.content || e.summary || ''
    entries.create(title:       (e.title unless e.title.blank?),
                   description: sanitize(strip_tags(description)),
                   pub_date:    find_date(e.published),
                   image:       find_image(e, description),
                   url:         e.url)
  end

  def find_date(pub_date)
    return Time.zone.now if pub_date.nil? || pub_date > Time.zone.now
    pub_date
  end

  def find_image(entry, desc)
    cached_images.find_by(entry_url: entry.url).image
  rescue
    img = (process_image image_from_description(desc), :desc) ||
          (process_image entry.image, :media) ||
          (process_image og_image(entry.url), :og)
    cached_images.create(entry_url: entry.url,
                         image: img)
    img
  end

  def process_image(img, source)
    return if img.blank?
    img = discard_non_images parse_image img
    hacks img, source
  end

  def parse_image(img)
    # Need to add http here as some images won't
    # load because ssl_error_bad_cert_domain
    return 'http:' + img if img.start_with?('//')
    uri = URI.parse feed_url
    start = uri.scheme + '://' + uri.host
    return start + img if img.start_with? '/'
    return start + uri.path + img unless img.start_with? 'http'
    img
  end

  def image_from_description(description)
    doc = Nokogiri::HTML description
    return doc.css('img').first.attributes['src'].value
  rescue
    nil
  end

  def og_image(url)
    require 'open-uri'
    doc = Nokogiri::HTML(open(URI.escape(url.strip.split(/#/).first)))
    img = doc.css("meta[property='og:image']").first
    return img.attributes['content'].value
  rescue
    nil
  end

  def hacks(img, source)
    return if img.blank?

    # replaces
    if img.start_with? 'http://i2.cdn.turner.com/cnn'
      img.sub!('top-tease', 'horizontal-gallery')
      img.sub!('cnn', 'cnnnext')
    elsif img.start_with? 'http://timedotcom.files'
      img.sub!('quality=75&strip=color&', '')
      img.sub!(/w=\d*/, 'w=400')
    elsif img.include? 'assets.rollingstone.com'
      img.sub!('small_square', 'medium_rect')
      img.sub!('100x100', '720x405')
    elsif img.include? 'imguol.com'
      img.sub!(/\d\d\dx\d\d\d/, '615x300')
    elsif img.include? 'carplace.uol.com'
      img.sub!(/-\d\d\dx\d\d\d/, '')
    elsif img.include? 'a57.foxnews.com/media.foxbusiness.com'
      img.sub!('121/68', '605/340')
    elsif img.include? 'fortunedotcom'
      img.sub!('quality=80&', '')
      img.sub!('w=150', 'w=450')
    elsif img.include? 'static.gamespot.com'
      img.sub!('.png', '.jpg')
      img.sub!('screen_medium', 'screen_kubrick')
      img.sub!('static', 'static1')
    elsif img.include? 'pmcvariety.files'
      img.sub!(/w=\d*/, 'w=400')
    elsif img.include? 'pmcdeadline2.files'
      img.sub!(/w=\d*/, 'w=400')
    elsif img.include? 'imagesmtv-a.akamaihd.net'
      img.sub!('quality=0.8&format=jpg&', '')
      img.sub!('width=150&height=150', 'width=400&height=300')
    elsif img.include? 'www.billboard.com'
      img.sub!('promo_225', 'promo_650')
    elsif img.include? 'graphics8.nytimes.com'
      img.sub!('moth.jpg', 'master675.jpg')
      img.sub!(/moth-v\d\.jpg/, 'master675.jpg')
      img.sub!('thumbStandard', 'superJumbo')
    elsif img.include? 'i.livescience.com'
      img.sub!('i00', 'iFF')
    elsif (img.include? 'img.huffingtonpost.com') || (img.include? 'i.huffpost.com')
      return if img.include? '-mini'
      img.sub!('74_54', '1200_630')
      img.sub!('74_58', '1200_630')
    elsif img.include? 'static.nfl.com'
      img.sub!('_thumbnail_200_150', '')
    elsif img.include? 'cbsistatic.com' # CNET
      return if source == :media
    end

    # blanks
    if (img.include? 'mf.gif') ||
       (img.include? 'blank') ||
       (img.include? 'pixel.wp') ||
       (img.include? 'pixel.gif') ||
       (img.include? 'Badge') ||
       (img.include? 'ptq.gif') ||
       (img.include? 'wirecutter-deals-300x250.png') ||
       (img.include? 'beacon') ||
       (img.include? 'rssfeeds.usatoday.com') ||
       (img.include? 'architecturaldigest.com/ad') ||
       (img.include? 'doubleclick.net') ||
       (img.include? 'amazon-adsystem.com') ||
       (img.include? 'feeds.commarts.com/~/i/') ||
       (img.include? 'wordpress.com/1.0/delicious') ||
       (img == 'http://www.scientificamerican.com') ||
       (img == 'http://eu.square-enix.com')
      return nil
    end

    # special cases
    if (img.include? 'feedburner') ||
       (img == 'http://newsimg.bbc.co.uk/media/images/67165000/jpg/_67165916_67165915.jpg') || # BBC
       (img.start_with? 'http://c.files.bbci.co.uk') && source == :media || # BBC Sport
       (img.include? 'a57.foxnews.com') && source == :media || # FOX
       (img == 'http://global.fncstatic.com/static/v/all/img/og/og-fn-foxnews.jpg') ||
       (img == 'http://www.foxsports.com/content/fsdigital/fscom.img.png') ||
       (img.include? 'images.gametrailers.com') && source == :desc || # GameTrailers
       (img.include? 'feedsportal') || # Various
       (img.include? 'feeds.huffingtonpost.com') || # Huffington Post
       (img.include? '_logo') || # Laissez Faire
       (img.include? 'forbes_200x200') || # Forbes
       (img.include? 'forbes_1200x1200') || # Forbes
       (img.include? 'share-button') || # Fapesp
       (img.include? 'wp-content/plugins') || # Wordpress share plugins
       (img.include? 'clubedohardware.com.br') || # Clube do Hardware
       (img.include? 'pml.png') || # Techmeme
       (img.include? 'wp-includes/images/smilies') || # Treehouse (and others)
       (img.include? 'slashcdn.com/sd') || # Slashdot
       (img.include? 'pixel.gif') || # Bleacher Report
       (img.include? 'avclub/None') || # A.V. Club
       (img.include? 'cdn.sstatic.net/stackoverflow') || # Stack Overflow
       (img.include? '.gravatar.com') || # Feedly, FB Newsroom
       (img.include? 'fastcompany.net/asset_files') || # Fastcompany
       (img.include? 'wordpress.com/1.0/comments') || # Wordpress
       (img.include? 'images/share') || # EFF
       (img.include? 'modules/service_links') || # KDE Dot News
       (img.include? 'badge') || # Cato.org
       (img.include? 'dynamic1.anandtech.com') || # Anandtech
       (img.include? '/icons/') || # EFF
       (img.include? '/emoji/') || # Bothsides of the Table
       (img.include? 'divisoriagizmodo') || # Gizmodo
       (img.include? 'index.phpstyles') || # Forum Outerspace
       (img.include? 'advertisement.') || # Smashing
       (img.include?('_thumb') && img.include?('goal.com')) || # Goal.com
       (img.include? ';base64,') # Bittorrent
      return nil
    end
    img
  end

  def discard_non_images(img)
    if (img.include? '.mp3') ||
       (img.include? '.tiff') ||
       (img.include? '.m4a') ||
       (img.include? '.mp4') ||
       (img.include? '.psd') ||
       (img.include? '.pdf') ||
       (img.include? '.webm') ||
       (img.include? '.svg') ||
       (img.include? '.ogv') ||
       (img.include? '.opus')
      return nil
    end
    img
  end
end
