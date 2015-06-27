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
    return if self.entries.any? and self.updated_at > 1.hour.ago
    self.update_attribute(:updated_at, Time.zone.now)
    feed = fetch_and_parse
    return if feed.is_a? Integer
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
    self.update_attributes(title: feed.title, site_url: process_url(feed.url || feed.feed_url))

    entries = feed.entries.first(Feed.entries_per_feed).reverse

    updated = false
    entries.each do |e|
      unless self.entries.find_by(url: e.url)
        insert_entry e
        updated = true
      end
    end

    if updated
      self.entries = self.entries.last Feed.entries_per_feed
      self.subscriptions.each { |s| s.update_attribute(:updated, true) }
    end
  end

  def has_new_entries?(entries)
    entries.each do |e|
      return true unless self.entries.find_by(url: e.url)
    end
    false
  end

  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element("enclosure", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:thumbnail", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("img", :value => :src, :as => :image)
    #Feedjira::Feed.add_common_feed_entry_element("media:content", :value => :url, :as => :image)
  end

  def insert_entry(e)
    description = e.content || e.summary || ""
    self.entries.create(title:       (e.title if not e.title.blank?),
                        description: sanitize(strip_tags(description)).first(400),
                        pub_date:    e.published || Time.zone.now,
                        image:       find_image(e, description),
                        url:         e.url)
  end

  def find_image(entry, description)
    return process_image(find_image_from_description(description)) ||
           process_image(entry.image)
  end

  def process_image(img)
    if img.nil? || img.blank?
      return nil
    end

    # maybe not needed anymore... let's see
    # uri = URI.uri(self.site_url || self.feed_url)
    # if img.start_with? '//'
    #   img = "http:" + img
    # elsif img.start_with? '/'
    #   img = uri.scheme + '://' + uri.host + img
    # elsif img.start_with? '../'
    #   img = uri.scheme + '://' + uri.host + img[2..-1]
    # elsif !img.start_with? 'http'
    #   img = uri.scheme + '://' + uri.host + uri.path + img
    # end

    return img
  end

  def find_image_from_description(description)
    begin
      doc = Nokogiri::HTML description
      doc.css('*').each do |e|
        if e.name == "img"
          return e.attributes['src'].value
        elsif e.name == "p" && !e.text.blank?
          break
        end
      end
    rescue
    end
    return nil
  end

  def find_og_image(url)
    begin
      doc = Nokogiri::HTML(open(URI::escape(url.strip.split(/#|\?/).first)))
      return doc.css("meta[property='og:image']").first.attributes['content'].value
    rescue
    end
  end

  def filter_image(img)
    # resize techcrunch images
    if img.include? 'images.wrc.com'
      img += '_896x504.jpg'
    end

    if img.include? '.tiff' or
      img.include? '.mp3' or
      img.include? '.m4a' or
      img.include? '.mp4' or
      img.include? '.psd' or
      img.include? '.gif' or
      img.include? '.pdf' or
      img.include? '.webm' or
      img.include? '.ogv' or
      img.include? '.opus'
      return nil
    else
      return img
    end
  end

end
