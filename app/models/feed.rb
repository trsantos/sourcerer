class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include ApplicationHelper
  include EntriesHelper

  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :feed_url, presence: true, uniqueness: true

  def self.entries_per_feed
    10
  end

  def update
    fj_feed = fetch_and_parse
    return if fj_feed.is_a? Integer
    # entries.delete_all
    update_feed_attributes fj_feed
    update_entries fj_feed
  end

  def only_images?
    entries.each do |e|
      return false unless e.image && e.description.blank?
    end
    true
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
                      logo: fj_feed.logo)
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
                   description: sanitize(strip_tags(description)).first(300),
                   pub_date:    find_date(e.published),
                   image:       find_image(e, description),
                   url:         e.url)
  end

  def find_date(pub_date)
    return Time.zone.now if pub_date.nil? || pub_date > Time.zone.now
    pub_date
  end

  def find_image(entry, description)
    process_image(image_from_description(description)) ||
      process_image(entry.image)
  end

  def process_image(img)
    return if img.blank?
    img = parse_image img
    filter_image img
  end

  def parse_image(img)
    return img if img.start_with?('//')
    uri = URI.parse(feed_url || site_url) # just use feed_url?
    start = uri.scheme + '://' + uri.host
    return start + img if img.start_with? '/'
    return start + uri.path + img unless img.start_with? 'http'
    img
  end

  def image_from_description(description)
    doc = Nokogiri::HTML description
    return filter_image doc.css('img').first.attributes['src'].value
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

  def filter_image(img)
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
       (img == 'http://www.scientificamerican.com') ||
       (img == 'http://eu.square-enix.com')
      return nil
    end

    # special cases
    if (img.include? 'feedburner') ||
       (img.include? 'feedsportal') || # Various
       (img.include? 'share-button') || # Fapesp
       (img.include? 'wp-content/plugins') || # W||dpress share plugins
       (img.include? 'clubedohardware.com.br') || # Clube do Hardware
       (img.include? 'pml.png') || # Techmeme
       (img.include? 'wp-includes/images/smilies') || # Treehouse (and others)
       (img.include? 'fsdn.com') || # Slashdot
       (img.include? 'pixel.gif') || # Bleacher Report
       (img.include? 'avclub/None') || # A.V. Club
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
       (img.include?('_thumb') && img.include?('goal.com')) || # Goal.com
       (img.include? ';base64,') # Bittorrent
      return nil
    end

    # non-image formats
    if (img.include? '.mp3') ||
       (img.include? '.tiff') ||
       (img.include? '.m4a') ||
       (img.include? '.mp4') ||
       (img.include? '.psd') ||
       # (img.include? '.gif') ||
       (img.include? '.pdf') ||
       (img.include? '.webm') ||
       (img.include? '.ogv') ||
       (img.include? '.opus')
      return nil
    end

    img
  end
end
