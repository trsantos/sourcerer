class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include ApplicationHelper

  belongs_to :topic

  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :feed_url, presence: true, uniqueness: true

  def self.entries_per_feed
    10
  end

  def self.update_all
    find_each { |f| f.delay.update }
  end

  def update
    fj_feed = fetch_and_parse
    return if fj_feed.is_a? Integer
    transaction do
      update_entries fj_feed
      update_feed_attributes fj_feed
    end
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
    Feedjira::Feed.fetch_and_parse feed_url
  rescue
    0
  end

  def update_feed_attributes(fj_feed)
    logo = check_feed_logo(fj_feed.logo)
    update_attributes(title: fj_feed.title,
                      site_url: process_url(fj_feed.url),
                      description: sanitize(strip_tags(fj_feed.description)),
                      logo: logo,
                      updated_at: Time.current)
  end

  def check_feed_logo(logo)
    return if logo.nil?
    if (logo.include? 'wp.com/i/buttonw-com'.freeze) ||
       (logo.include? 'creativecommons.org/images/public'.freeze)
      nil
    else
      logo
    end
  end

  def update_entries(fj_feed)
    return unless new_entries? fj_feed
    entries.delete_all
    fj_feed.entries.first(Feed.entries_per_feed).reverse_each do |e|
      insert_entry e
    end
    subscriptions.where(updated: false).update_all(updated: true)
  end

  def new_entries?(fj_feed)
    fj_feed.entries.first(3).each do |e|
      return true unless entries.exists?(url: e.url)
    end
    false
  end

  # This should be done only once...
  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element(:enclosure,
                                                 value: :url, as: :image)
    Feedjira::Feed.add_common_feed_entry_element('media:thumbnail'.freeze,
                                                 value: :url, as: :image)
    Feedjira::Feed.add_common_feed_entry_element('media:content'.freeze,
                                                 value: :url, as: :image)
    Feedjira::Feed.add_common_feed_entry_element(:img, value: :scr, as: :image)
    Feedjira::Feed.add_common_feed_element(:url, as: :logo, ancestor: :image)
    Feedjira::Feed.add_common_feed_element(:logo, as: :logo)
  end

  def insert_entry(e)
    description = e.content || e.summary || ''.freeze
    entries.create(title:       (e.title unless e.title.blank?),
                   description: sanitize(strip_tags(description)),
                   pub_date:    find_date(e.published),
                   image:       find_image(e, description),
                   url:         e.url)
  end

  def find_date(pub_date)
    return Time.current if pub_date.nil? || pub_date > Time.current
    pub_date
  end

  def find_image(entry, desc)
    process_image entry.image || image_from_description(desc)
  rescue
    nil
  end

  def process_image(img)
    hacks discard_non_images parse_image img
  end

  def parse_image(img)
    # Need to add http here as some images won't
    # load because ssl_error_bad_cert_domain
    return 'http:'.freeze + img if img.start_with?('//'.freeze)
    uri = URI.parse feed_url
    start = uri.scheme + '://'.freeze + uri.host
    return start + img if img.start_with? '/'.freeze
    # I don't remeber why this is here. Maybe not needed?
    return start + uri.path + img unless img.start_with? 'http'.freeze
    img
  end

  def image_from_description(description)
    doc = Nokogiri::HTML description
    doc.css('img'.freeze).first.attributes['src'.freeze].value
  end

  def og_image(url)
    require 'open-uri'
    doc = Nokogiri::HTML(open(URI.escape(url.strip.split(/#/).first)))
    img = doc.css("meta[property='og:image']".freeze).first
    img.attributes['content'.freeze].value
  end

  def hacks(img)
    # replaces
    if img.include? 'wordpress.com'.freeze
      img.sub!(/\?.*/, ''.freeze)
      img += '?w=400'.freeze
    elsif (img.include? 'img.youtube.com'.freeze) ||
          (img.include? 'i.ytimg.com'.freeze)
      img.sub! '/default'.freeze, '/hqdefault'.freeze
    elsif (img.include? 'googleusercontent.com'.freeze) ||
          (img.include? 'blogspot.com'.freeze)
      img.sub! 's72-c'.freeze, 's640'.freeze
    end

    # special cases
    if (img.include? 'feedburner.com'.freeze) ||
       (img.include? 'feedsportal.com'.freeze) ||
       (img.include? '/comments/'.freeze) # Wordpress
      return nil
    end

    img
  end

  def discard_non_images(img)
    if (img.include? '.mp3'.freeze) ||
       (img.include? '.tiff'.freeze) ||
       (img.include? '.m4a'.freeze) ||
       (img.include? '.mp4'.freeze) ||
       (img.include? '.psd'.freeze) ||
       (img.include? '.pdf'.freeze) ||
       (img.include? '.webm'.freeze) ||
       (img.include? '.svg'.freeze) ||
       (img.include? '.ogv'.freeze) ||
       (img.include? '.opus'.freeze)
      return nil
    end
    img
  end
end
