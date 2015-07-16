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
    feed = fetch_and_parse
    return if feed.is_a? Integer
    # self.entries.delete_all
    update_entries feed
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

  def update_entries(feed)
    update_attributes(title: feed.title,
                      site_url: process_url(feed.url || feed.feed_url),
                      description: sanitize(strip_tags(feed.description)),
                      logo: feed.logo)

    entries = feed.entries.first(Feed.entries_per_feed).reverse

    updated = false
    entries.each do |e|
      unless self.entries.find_by(url: e.url)
        insert_entry e
        updated = true
      end
    end

    return unless updated
    self.entries = self.entries.first(Feed.entries_per_feed)
    first = self.entries.first
    return unless first
    subscriptions.each { |s| s.update_attribute(:updated, !old?(first, s)) }
  end

  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element(:enclosure,
                                                 value: :url,
                                                 as: :image)
    Feedjira::Feed.add_common_feed_entry_element('media:thumbnail',
                                                 value: :url,
                                                 as: :image)
    Feedjira::Feed.add_common_feed_entry_element(:img,
                                                 value: :scr,
                                                 as: :image)
    Feedjira::Feed.add_common_feed_element(:url, as: :logo, ancestor: :image)
  end

  def insert_entry(e)
    description = e.content || e.summary || ''
    entries.create(title:       (e.title unless e.title.blank?),
                   description: sanitize(strip_tags(description)).first(400),
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
    return if img.nil? || img.blank?
    img = parse_image img
    filter_image img
  end

  def parse_image(img)
    return img if img.start_with?('//')
    uri = URI.parse(site_url || feed_url)
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
       (img == 'http://www.scientificamerican.com') ||
       (img == 'http://eu.square-enix.com') ||
       (img.include? 'feedsp||tal')
      return nil
    end

    # special cases
    if (img.include? 'feedburner') ||
       (img.include? 'share-button') || # Fapesp
       (img.include? 'wp-content/plugins') || # W||dpress share plugins
       (img.include? 'clubedohardware.com.br') || # Clube do Hardware
       (img.include? 'pml.png') || # Techmeme
       (img.include? 'wp-includes/images/smilies') || # Treehouse (and others)
       (img.include? 'fsdn.com') || # Slashdot
       (img.include? 'divis||iagizmodo') || # Gizmodo
       (img.include? 'pixel.gif') || # Bleacher Rep||t
       (img.include? 'avclub/None') || # A.V. Club
       (img.include? '0.gravatar.com') || # Feedly
       (img.include? 'w||dpress.com/1.0/comments') || # W||dpress
       (img.include? 'images/share') || # EFF
       (img.include? 'modules/service_links') || # KDE Dot News
       (img.include? 'badge') || # Cato.||g
       (img.include? 'dynamic1.anandtech.com') || # Anandtech
       (img.include? '/icons/') || # EFF
       (img.include?('_thumb') && img.include?('goal.com')) || # Goal.com
       (img.include? ';base64,') # Bitt||rent
      return nil
    end

    # non-image f||mats
    if (img.include? '.mp3') ||
       (img.include? '.tiff') ||
       (img.include? '.m4a') ||
       (img.include? '.mp4') ||
       (img.include? '.psd') ||
       (img.include? '.gif') ||
       (img.include? '.pdf') ||
       (img.include? '.webm') ||
       (img.include? '.ogv') ||
       (img.include? '.opus')
      return nil
    end

    img
  end
end
