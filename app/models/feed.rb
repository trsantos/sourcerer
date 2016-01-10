# frozen_string_literal: true

class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include ApplicationHelper

  belongs_to :topic
  has_many :subscriptions, dependent: :delete_all
  has_many :users, through: :subscriptions
  has_many :entries, dependent: :delete_all

  validates :feed_url, presence: true, uniqueness: true
  after_create :delayed_update

  def self.entries_per_feed
    10
  end

  def self.update_all_feeds(pool_size = 10)
    require 'thread/pool'
    pool = Thread.pool(pool_size)
    Feed.find_each do |f|
      pool.process do
        f.update
        ActiveRecord::Base.connection.close
      end
    end
    pool.shutdown
  end

  def update
    puts id
    fj_feed = fetch_and_parse
    return if fj_feed.is_a? Integer
    transaction do
      update_entries fj_feed
      update_feed_attributes fj_feed
    end
  rescue => e
    puts id, e
    retry
  end

  def only_images?
    entries.each do |e|
      return false unless e.image && (strip_tags e.description).blank?
    end
    true
  end

  private

  def fetch_and_parse
    setup_fj
    Feedjira::Feed.fetch_and_parse feed_url
  rescue
    update_attribute :fetching, false
    0
  end

  def update_feed_attributes(fj_feed)
    update_attributes(title: fj_feed.title,
                      site_url: process_url(fj_feed.url),
                      description: fj_feed.description,
                      logo: check_feed_logo(fj_feed.logo),
                      has_only_images: only_images?,
                      fetching: false,
                      updated_at: Time.current)
  end

  def check_feed_logo(logo)
    return if logo.nil?
    if (logo.include? 'wp.com/i/buttonw-com') ||
       (logo.include? 'creativecommons.org/images/public')
      nil
    else
      logo
    end
  end

  def update_entries(fj_feed)
    fj_feed.entries.first(Feed.entries_per_feed).reverse_each do |fj_entry|
      insert_or_update_entry fj_entry
    end
    return unless entries.count > Feed.entries_per_feed
    discard_old_entries
    mark_subscriptions_as_updated
  end

  def discard_old_entries
    self.entries = entries.order(updated_at: :desc).first(Feed.entries_per_feed)
  end

  def mark_subscriptions_as_updated
    subscriptions.where(updated: false).update_all(updated: true)
  end

  def insert_or_update_entry(fj_entry)
    entries.find_by(url: fj_entry.url).touch
  rescue
    insert_entry fj_entry
  end

  def insert_entry(e)
    description = e.content || e.summary || ''
    entries.create(title:       (e.title unless e.title.blank?),
                   description: description,
                   pub_date:    find_date(e.published),
                   image:       find_image(e, description),
                   url:         e.url)
  end

  def setup_fj
    Feedjira::Feed
      .add_common_feed_entry_element(:enclosure, value: :url, as: :image)
    Feedjira::Feed
      .add_common_feed_entry_element('media:thumbnail', value: :url, as: :image)
    Feedjira::Feed
      .add_common_feed_entry_element('media:content', value: :url, as: :image)

    Feedjira::Feed.add_common_feed_element(:url, as: :logo, ancestor: :image)
    Feedjira::Feed.add_common_feed_element(:logo, as: :logo)
  end

  def find_date(pub_date)
    return Time.current if pub_date.nil? || pub_date > Time.current
    pub_date
  end

  def find_image(entry, desc)
    process_image entry.image || image_from_description(desc)
  end

  def process_image(img)
    return if bad_image?(img)
    hacks parse_image img
  end

  def parse_image(img)
    # Need to add http here as some images won't
    # load because ssl_error_bad_cert_domain
    return 'http:' + img if img.start_with?('//')
    uri = URI.parse feed_url
    start = uri.scheme + '://' + uri.host
    return start + img if img.start_with? '/'
    # I don't remeber why this is here. Maybe not needed?
    return start + uri.path + img unless img.start_with? 'http'
    img
  end

  def image_from_description(description)
    doc = Nokogiri::HTML description
    doc.css('img').first.attributes['src'].value
  rescue
    nil
  end

  def hacks(img)
    if img.include? 'wordpress.com'
      img.sub!(/\?.*/, '')
      img += '?w=800'
    elsif (img.include? 'img.youtube.com') || (img.include? 'i.ytimg.com')
      img.sub! '/default', '/hqdefault'
    elsif (img.include? 'googleusercontent.com') ||
          (img.include? 'blogspot.com')
      img.sub! 's72-c', 's640'
    end
    img
  end

  def bad_image?(img)
    (img.nil?) ||
      (img.include? 'feedburner.com') ||
      (img.include? 'feedsportal.com') ||
      (img.include? '/comments/') # Wordpress
  end

  def delayed_update
    delay.update
  end
end
