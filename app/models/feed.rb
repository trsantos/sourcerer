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
    # return if entries.any? && updated_at > 2.hours.ago && Rails.env.production?
    fj_feed = fetch_and_parse
    return if fj_feed.is_a? Integer
    entries.delete_all if Rails.env.development?
    update_feed_attributes fj_feed
    update_entries fj_feed
  end

  def only_images?
    (feed_url.include? 'youtube.com/feeds/videos.xml') ||
      (feed_url.include? 'expo.getbootstrap.com') ||
      (feed_url.include? 'xkcd.com/rss.xml')
  end

  def refresh_images
    fj_feed = fetch_and_parse
    return if fj_feed.is_a? Integer
    entries.delete_all
    fj_feed.entries.first(Feed.entries_per_feed).reverse_each do |e|
      insert_entry e
    end
    self.entries = entries.order(created_at: :desc).first(Feed.entries_per_feed)
  end

  private

  def fetch_and_parse
    setup_fj
    return Feedjira::Feed.fetch_and_parse feed_url
  rescue
    0
  end

  def update_feed_attributes(fj_feed)
    logo = check_feed_logo(fj_feed.logo)
    update_attributes(title: fj_feed.title,
                      site_url: process_url(fj_feed.url || fj_feed.feed_url),
                      description: sanitize(strip_tags(fj_feed.description)),
                      logo: logo,
                      updated_at: Time.zone.now)
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
      unless entries.find_by(url: e.url)
        insert_entry e
        updated = true
      end
    end
    self.entries = entries.order(created_at: :desc).first(Feed.entries_per_feed)
    update_subscriptions if updated
  end

  def update_subscriptions
    subscriptions.each do |s|
      s.update_attribute(:updated, true)
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
    return Time.current if pub_date.nil? || pub_date > Time.zone.now
    pub_date
  end

  def find_image(entry, desc)
    (process_image image_from_description(desc), :desc) ||
      (process_image entry.image, :media) ||
      (process_image og_image(entry.url), :og)
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
    seen_text = false
    doc.css('*').each do |e|
      if e.name == 'img'
        return e.attributes['src'].value
      elsif e.name == 'p' && !e.text.blank?
        if seen_text
          break
        else
          seen_text = true
        end
      end
    end
    nil
    # return doc.css('img').first.attributes['src'].value
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
    if img.include? 'pitchfork.com'
      img.sub! 'pagination.', 'ticker.'
    elsif img.include? 'cdn.turner.com'
      img.sub! 'top-tease', 'horizontal-gallery'
      img.sub! 'cnn', 'cnnnext'
      img.sub! '120x90', '780x439'
    elsif img.include? 'wordpress.com'
      img.sub!(/w=\d*/, 'w=400')
      img.sub!(/quality=\d*/, '')
    elsif img.include? 'assets.rollingstone.com'
      img.sub!('small_square', 'medium_rect')
      img.sub!('100x100', '720x405')
    elsif img.include? 'imguol.com'
      img.sub!(/\d\d\dx\d\d\d/, '615x300')
    elsif img.include? 'carplace.uol.com'
      img.sub!(/-\d\d\dx\d\d\d/, '')
    elsif img.include? 'a57.foxnews.com/media.foxbusiness.com'
      img.sub!('121/68', '605/340')
    elsif img.include? 'static.gamespot.com'
      img.sub!('.png', '.jpg')
      img.sub!('screen_medium', 'screen_kubrick')
      img.sub!('static', 'static1')
    elsif img.include? 'imagesmtv-a.akamaihd.net'
      img.sub!('quality=0.8&format=jpg&', '')
      img.sub!('width=150&height=150', 'width=400&height=300')
    elsif img.include? 'www.billboard.com'
      img.sub!('promo_225', 'promo_650')
    elsif img.include? 'graphics8.nytimes.com'
      # img.sub!('moth', 'master675')
      img.sub!(/moth(\-v\d+|)/, 'master675')
      img.sub! 'sub-', 'dd-'
      if img.include? 'bits-daily-report'
        img.sub!(/thumbStandard(-v\d|)/, 'articleInline')
      else
        img.sub!(/thumbStandard(-v\d|)/, 'superJumbo')
      end
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
    elsif img.include? 'media.breitbart.com'
      img.sub!(/-\d\d\dx\d\d\d/, '')
    elsif img.include? 'img.youtube.com'
      img.sub! '/default', '/hqdefault'
    elsif img.include? 'i.ytimg.com'
      img.sub! '/default', '/hqdefault'
    elsif img.include? 'blog.caranddriver.com'
      img.sub!(/-150x150/, '-876x535')
    elsif img.include? 'cienciahoje.uol.com.br'
      img.sub! '/image_mini', ''
    elsif img.include? 'news.sciencemag.org'
      img.sub!('styles/square_60x60/public', '')
    elsif img.include? 'images.eonline.com'
      img.sub!('/resize/66/66/', '')
    elsif img.include? 'fifa.com'
      img.sub!('small.', 'full-lnd.')
    elsif img.include? 'scontent.cdninstagram.com'
      img.sub!('s150x150', 's320x320')
    elsif img.include? 'img.washingtonpost.com'
      return if img.include? '.html'
      img.sub! '_90w', '_1024w'
      img.sub! 'w=90', 'w=1024'
    elsif img.include? 'media.bestofmicro.com'
      img.sub!(/rc_120x90/, 'w_600')
    elsif img.include? 'nikkei.com'
      img.sub!('thumbnail.jpg', '_main_image.jpg')
    elsif img.include? 'cdn.phys.org'
      img.sub!('tmb', '800')
    elsif img.include? 'scientificamerican.com'
      img.sub!('_small', '')
    elsif img.include? '365dm.com'
      img.sub! '128x67', '768x432'
      img.sub! '150x150', '768x432'
    elsif img.include? 'i.space.com'
      img.sub!('i00', 'i02')
    elsif img.include? 'static.spin.com'
      img.sub!(/-\d\d\dx\d\d\d/, '')
    elsif img.include? 'venturebeat.com'
      img.sub! '-160x140', ''
    elsif (img.include? 'googleusercontent.com') ||
          (img.include? 'blogspot.com')
      img.sub! 's72-c', 's640'
    end

    # blanks
    if (img.include? 'mf.gif') ||
       (img.include? 'blank') || # Wordpress
       (img.include? 'pixel.wp') || # Wordpress
       (img.include? 'pixel.gif') ||
       (img.include? 'beacon') || # Intel Blogs
       (img.include? 'rssfeeds.usatoday.com') ||
       (img.include? 'doubleclick.net') ||
       (img.include? 'feeds.commarts.com/~/i/') ||
       (img.include? 'img/.jpg') || # jezenthomas
       (img.include? 'AD5.') || # bip-online
       (img.include? 'GhOtcum4rbpO2RRCDXxaJDTBfc_large.png') || # Dustin Curtis
       (img == 'http://www.scientificamerican.com') ||
       (img == 'http://eu.square-enix.com') || # Square
       (img.include? 'wp-content/themes') # Intel Blogs
      return nil
    end

    # # special cases
    if (img.include? 'feedburner.com') ||
       (img.include? 'logo') ||
       (img.include? 'icon') ||
       (img.include? '/themes/') ||
       (img.include? '/plugins/') ||
       (img.include? '/smilies/') ||
       (img.include? '/emoji/') ||
       (img.include? '/smileys/') ||
       (img.include? 'a57.foxnews.com') && source == :media || # FOX
       (img == 'http://global.fncstatic.com/static/v/all/img/og/og-fn-foxnews.jpg') ||
       (img == 'http://www.foxsports.com/content/fsdigital/fscom.img.png') ||
       (img == 'http://newsimg.bbc.co.uk/media/images/67165000/jpg/_67165916_67165915.jpg') ||
       (img.include?('_thumb') && img.include?('goal.com')) || # Goal.com
       (img.include? 'media.guim.co.uk') || # Guardian
       (img.include? 'images.gametrailers.com') && source == :desc || # GameTrailers
       (img.include? 'feedsportal.com') || # Various
       (img.include? 'feeds.huffingtonpost.com') || # Huffington Post
       (img.include? 'forbes_200x200') || # Forbes
       (img.include? 'forbes_1200x1200') || # Forbes
       (img.include? 'text_200.png') || # Tumblr
       (img.include? 'tumblr.com/avatar') || # Tumblr
       (img.include? 'clubedohardware.com.br') || # Clube do Hardware
       (img.include? 'techmeme.com') || # Techmeme
       (img.include? 'twitter_icon_large') || # Slashdot
       (img.include? 'avclub/None') || # A.V. Club
       (img.include? 'cdn.sstatic.net/stackoverflow') || # Stack Overflow
       (img.include? 'gravatar.com') || # Feedly, FB Newsroom
       (img.include? 'fastcompany.net/asset_files') || # Fastcompany
       (img.include? 'advertisement.') || # Smashing
       (img.include? 's3.cooperpress.com') || # HTML5 Weekly
       (img.include? 'wp.com/latex.php') || # Wordpress
       (img.include? 'css-tricks-star.png') || # CSS Tricks
       (img.include? 's.conjur.com.br/img/a/og.png') || # Conjur
       (img.include? 'shim-640x20.png') || # EO Wilson
       (img.include? 'ephotozine.com') || # ePHOTOzine
       (img.include? 'hands-anim.gif') || # jwz
       (img.include? 'mediagazer.com') || # Mediagazer
       (img.include? 'www.spiegel.de/images') && source != :og || # Spiegel
       (img.include? 'golem.de') && source == :desc || # Golem.de
       (img.include? 'media.mmo-champion.com') || # Heroes Nexus
       (img.include? 'alternativeto-a.png') || # AlternativeTo
       (img.include? 'buffed.de') ||
       (img.include? 'dx.plos.org') ||
       (img.start_with? 'http://c.files.bbci.co.uk') && source == :media
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
