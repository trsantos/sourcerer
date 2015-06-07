class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy
  
  validates :feed_url, presence: true, uniqueness: true

  def update
    # Continue with the update
    # IF the feed was just created OR its last update was before 1 hour ago
    return if self.updated_at > 1.hour.ago and self.entries.any?

    feed = fetch_and_parse

    if feed.is_a? Integer
      puts "Could not update #{self.id}, #{self.feed_url}"
      return
    end

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
    return Feedjira::Feed.fetch_and_parse self.feed_url
  end

  def update_entries(feed)
    self.update_attributes(title:    feed.title,
                           site_url: feed.url || feed.feed_url)

    updated = false

    entries = feed.entries.first(5).reverse
    entries.each do |e|
      unless self.entries.find_by(url: e.url) or self.entries.find_by(title: e.title)
        updated = true
        insert_entry e
      end
    end

    if updated
      self.entries = self.entries.first 5
    end
  end

  def setup_fj
    Feedjira::Feed.add_common_feed_entry_element("enclosure", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:thumbnail", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:content", :value => :url, :as => :image)
  end

  def insert_entry(e)
    description = e.content || e.summary || ""
    self.entries.create(title:       e.title,
                        description: sanitize(strip_tags(description)).first(300),
                        pub_date:    find_pub_date(e.published),
                        image:       find_image(e, description),
                        url:         e.url)
  end

  def find_pub_date(date)
    if date.nil? or date > Time.zone.now
      Time.zone.now
    else
      date
    end
  end

  def find_image(entry, description)
    return process_image(entry.image) ||
           process_image(find_image_from_description(description))
  end

  def process_image(img)
    if img.nil? || img.blank?
      return nil
    end

    if img.start_with? '//'
      img = "http:" + img
    elsif img.start_with? '/'
      parse = URI.parse self.feed_url
      img = parse.scheme + '://' + parse.host + img
    elsif img.start_with? '../'
      parse = URI.parse self.url
      img = parse.scheme + '://' + parse.host + img[2..-1]
    end

    return filter_image img
  end

  def find_image_from_description(description)
    begin
      doc = Nokogiri::HTML description
      return doc.css('img').first.attributes['src'].value
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
    if img.include? 'tctechcrunch2011'
      img += '?w=400'
    end

    # discard silly images
    if img.include? 'feedburner' or
      img.include? 'pml.png' or
      img.include? '.gif' or
      img.include? '.tiff' or
      img.include? 'rc.img' or
      img.include? 'mf.gif' or
      img.include? 'ptq.gif' or
      img.include? 'twitter16.png' or
      img.include? 'sethsblog' or
      img.include? 'assets.feedblitz.com/i/' or
      img.include? 'wirecutter-deals' or
      img.include? '/heads/' or
      img.include? '/share/' or
      img.include? 'smile.png' or
      img.include? 'blank.' or
      img.include? 'application-pdf.png' or
      img.include? 'gif;base64' or
      img.include? 'abrirpdf.png' or
      img.include? 'gravatar.com/avatar' or
      img.include? 'nojs.php' or
      img.include? 'icon' or
      img.include? 'gplus-16.png' or
      img.include? 'logo' or
      img.include? 'avw.php' or
      img.include? 'tmn-test' or
      img.include? '-ipad-h' or
      img.include? 'webkit-fake-url' or
      img.include? '/img/oglobo.jpg' or
      img.include? 'beacon' or
      img.include? 'usatoday-newstopstories' or
      img.include? 'a2.img' or
      img.include? 'ach.img' or
      img.include? '/comments/' or
      img.include? '/smilies/' or
      img.include? 'a2t.img' or
      img.include? 'a2t2.img' or
      img.include? 'default-thumbnail' or
      img.include? 'subscribe.jpg' or
      img.include? 'forbes_' or
      img.include? 'transparent.png' or
      # Disable the next to filters when og images are not used
      # img.include? 'bbcimg.co.uk' or
      # img.include? '/images/facebook' or
      # img.include? 'phys.org/newman/csz/news/tmb' or
      # img.include? 'uol-jogos-600px' or
      img.include? '.mp3' or
      img.include? '.m4a' or
      img.include? '.mp4' or
      img.include? '.psd' or
      img.include? '.pdf' or
      img.include? '.ogv'
      return nil
    else
      return img
    end
  end

end
