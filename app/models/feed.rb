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
                      site_url: process_url(fj_feed.url || fj_feed.feed_url),
                      description: sanitize(strip_tags(fj_feed.description)),
                      logo: logo,
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
    updated = false
    fj_feed.entries.first(Feed.entries_per_feed).reverse_each do |e|
      unless entries.exists?(url: e.url)
        insert_entry e
        updated = true
      end
    end
    self.entries = entries.order(created_at: :desc).first(Feed.entries_per_feed)
    update_subscriptions if updated
  end

  def update_subscriptions
    subscriptions.where(updated: false).update_all(updated: true)
  end

  # This should be done only once...
  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element('media:thumbnail',
                                                 value: :url, as: :image)
    Feedjira::Feed.add_common_feed_entry_element(:img, value: :scr, as: :image)
    Feedjira::Feed.add_common_feed_element(:url, as: :logo, ancestor: :image)
    Feedjira::Feed.add_common_feed_element(:logo, as: :logo)
  end

  def insert_entry(e)
    description = e.content || e.summary || ''
    entries.create(title:       (e.title unless e.title.blank?),
                   description: sanitize(description,
                                         tags: ['a'],
                                         attributes: ['href']),
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
  end

  def og_image(url)
    require 'open-uri'
    doc = Nokogiri::HTML(open(URI.escape(url.strip.split(/#/).first)))
    img = doc.css("meta[property='og:image']").first
    img.attributes['content'].value
  end

  def hacks(img)
    # replaces
    if img.include? 'wordpress.com'
      img.sub!(/\?.*/, '')
      img += '?w=400'
    elsif (img.include? 'img.youtube.com') ||
          (img.include? 'i.ytimg.com')
      img.sub! '/default', '/hqdefault'
    elsif (img.include? 'googleusercontent.com') ||
          (img.include? 'blogspot.com')
      img.sub! 's72-c', 's640'
    end

    # special cases
    if (img.include? 'feedburner.com') ||
       (img.include? 'feedsportal.com') ||
       (img.include? '/comments/') # Wordpress
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
