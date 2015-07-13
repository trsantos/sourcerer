class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include ApplicationHelper

  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy
  
  validates :feed_url, presence: true, uniqueness: true

  def self.entries_per_feed
    return 10
  end

  def update
    feed = fetch_and_parse
    return if feed.is_a? Integer
    #self.entries.delete_all
    update_entries feed
  end

  def only_images?
    self.entries.each do |e|
      return false if !(e.image && e.description.blank?)
    end
    return true
  end

  private

  def fetch_and_parse
    setup_fj
    begin
      return Feedjira::Feed.fetch_and_parse self.feed_url
    rescue
    end
    return 0
  end

  def update_entries(feed)
    self.update_attributes(title: feed.title,
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

    if updated
      self.entries = self.entries.order(pub_date: :desc).first(Feed.entries_per_feed)
      first = self.entries.order(pub_date: :desc).first
      if first
        self.subscriptions.each { |s| s.update_attribute(:updated, (s.visited_at.nil? || first.pub_date > s.visited_at)) }
      end
    end
  end

  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element("enclosure", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:thumbnail", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:content", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("img", :value => :src, :as => :image)
    Feedjira::Feed.add_common_feed_element :url, as: :logo, ancestor: :image
  end

  def insert_entry(e)
    # Don't remember why content comes first
    description = e.content || e.summary || ""
    self.entries.create(title:       (e.title if not e.title.blank?),
                        description: sanitize(strip_tags(description)).first(400),
                        pub_date:    find_date(e.published),
                        image:       find_image(e, description),
                        url:         e.url)
  end

  def find_date(pub_date)
    if pub_date.nil? || pub_date > Time.zone.now
      return Time.zone.now
    end
    pub_date
  end

  def find_image(entry, description)
    return [image_from_description(description), entry.image].map{ |i| process_image i }.find{ |x| !x.nil? }
  end

  def process_image(img)
    if img.nil? || img.blank?
      return nil
    end

    uri = URI.parse(self.site_url || self.feed_url)
    if img.start_with?('//')
    # do nothing hoping that relative protocol urls works for the given site
    elsif img.start_with? '/'
      img = uri.scheme + '://' + uri.host + img
    elsif !img.start_with? 'http'
      img = uri.scheme + '://' + uri.host + uri.path + img
    # elsif img.start_with? 'http://'
    #   img = img[5..-1]
    end

    return filter_image img
  end

  def image_from_description(description)
    begin
      doc = Nokogiri::HTML description
      return filter_image doc.css('img').first.attributes['src'].value
    rescue
    end
    return nil
  end

  def og_image(url)
    begin
      require 'open-uri'
      doc = Nokogiri::HTML(open(URI::escape(url.strip.split(/#/).first)))
      return doc.css("meta[property='og:image']").first.attributes['content'].value
    rescue
    end
  end

  def filter_image(img)
    # blanks
    if img.include? 'mf.gif' or
      img.include? 'blank' or
      img.include? 'pixel.wp' or
      img.include? 'pixel.gif' or
      img.include? 'Badge' or
      img.include? 'ptq.gif' or
      img.include? 'wirecutter-deals-300x250.png' or
      img.include? 'beacon' or
      img == 'http://www.scientificamerican.com' or
      img == 'http://eu.square-enix.com' or
      img.include? 'feedsportal'
      return nil
    end

    # special cases
    if img.include? 'feedburner' or
      img.include? 'share-button' or # Fapesp
      img.include? 'wp-content/plugins' or # Wordpress share plugins
      img.include? 'clubedohardware.com.br' or # Clube do Hardware
      img.include? 'pml.png' or # Techmeme
      img.include? 'wp-includes/images/smilies' or # Treehouse (and others)
      img.include? 'fsdn.com' or # Slashdot
      img.include? 'divisoriagizmodo' or # Gizmodo
      img.include? 'pixel.gif' or # Bleacher Report
      img.include? 'avclub/None' or # A.V. Club
      img.include? '0.gravatar.com' or # Feedly
      img.include? 'wordpress.com/1.0/comments' or # Wordpress
      img.include? 'images/share' or # EFF
      img.include? 'modules/service_links' or # KDE Dot News
      img.include? 'badge' or # Cato.org
      img.include? 'dynamic1.anandtech.com' or # Anandtech
      img.include? '/icons/' or # EFF
      (img.include? '_thumb' and img.include? 'goal.com') or # Goal.com
      img.include? ';base64,' # Bittorrent
      return nil
    end

    # non-image formats
    if img.include? '.mp3' or
      img.include? '.tiff' or
      img.include? '.m4a' or
      img.include? '.mp4' or
      img.include? '.psd' or
      img.include? '.gif' or
      img.include? '.pdf' or
      img.include? '.webm' or
      img.include? '.ogv' or
      img.include? '.opus'
      return nil
    end

    return img
  end

end
