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
    #self.entries.destroy_all
    update_entries feed
  end

  def only_images?
    self.entries.each do |e|
      return false if !(e.image && e.description.blank?)
    end
    return true
  end

  # Too complicated, but seems to work.
  # Disable for now as I think that it's still better to load favicons dynamically.
  # def favicon_for
  #   begin
  #     uri = URI.parse self.site_url
  #     favicon = uri.scheme + '://' + uri.host + '/favicon.ico'
  #     if open(favicon)
  #       self.update_attribute(:favicon, favicon)
  #     else
  #       favicon = nil
  #       require 'open-uri'
  #       doc = Nokogiri::HTML open(uri.scheme + '://' + uri.host).read.downcase
  #       list = ['link[@rel="fluid-icon"]', 'link[@rel="shortcut icon"]', 'link[@rel="icon"]']
  #       favicon = list.map{ |x| doc.css(x) }.select{ |x| x.any? }.first
  #       if favicon
  #         f = favicon.attr('href').value
  #         if URI.parse(f).relative?
  #           f += uri.scheme + '://' + uri.host + '/' + f
  #         self.update_attribute(:favicon, f)
  #         end
  #       end
  #     end
  #   rescue
  #   end
  # end

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

  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element("enclosure", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:thumbnail", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:content", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("img", :value => :src, :as => :image)
  end

  def insert_entry(e)
    # Don't remember why content comes first
    description = e.content || e.summary || ""
    self.entries.create(title:       (e.title if not e.title.blank?),
                        description: sanitize(strip_tags(description)).first(400),
                        pub_date:    e.published || Time.zone.now,
                        image:       find_image(e, description),
                        url:         e.url.strip)
  end

  def find_image(entry, description)
    return process_image(image_from_description(description)) ||
           process_image(og_image(entry.url)) ||
           process_image(entry.image)
  end

  def process_image(img)
    if img.nil? || img.blank? || img == '0'
      return nil
    end

    uri = URI.parse(self.site_url || self.feed_url)
    if img.start_with? '//'
      img = "http:" + img
    elsif img.start_with? '/'
      img = uri.scheme + '://' + uri.host + img
    elsif img.start_with? '../'
      img = uri.scheme + '://' + uri.host + img[2..-1]
    elsif !img.start_with? 'http'
      # I don't remember why I added this one
      img = 'http://' + uri.host + uri.path + img
    end

    return filter_image img
  end

  def image_from_description(description)
    begin
      doc = Nokogiri::HTML description
      first_p = true
      doc.css('*').each do |e|
        if e.name == "img"
          return e.attributes['src'].value
        elsif e.name == "p"
          if first_p
            first_p = false
          else
            break
          end
        end
      end
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
      img.include? 'feedburner' or
      img.include? 'pixel.wp' or
      img.include? 'Badge' or
      img.include? 'beacon'
      return nil
    end

    # special cases
    if img.include? 'share-button' or # Fapesp
      img.include? '_thumb' # Goal.com
      return nil
    end

    # non-image formats
    if img.include? '.mp3' or
      # img.include? '.tiff' or
      img.include? '.m4a' or
      img.include? '.mp4' or
      img.include? '.psd' or
      # img.include? '.gif' or
      img.include? '.pdf' or
      img.include? '.webm' or
      img.include? '.ogv' or
      img.include? '.opus'
      return nil
    end

    return img
  end

end
