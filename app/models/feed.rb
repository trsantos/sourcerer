class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  # has_many :subscriptions, dependent: :destroy
  # has_many :users, through: :subscriptions
  has_many :entries, dependent: :destroy
  
  validates :feed_url, presence: true, uniqueness: true

  def update
    return if self.updated_at > 24.hour.ago and self.entries.count > 0

    Feedjira::Feed.add_common_feed_entry_element("enclosure", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:thumbnail", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:content", :value => :url, :as => :image)

    begin
      self.update_attribute(:updated_at, Time.zone.now)
      feed = Feedjira::Feed.fetch_and_parse self.feed_url
    rescue Rack::Timeout::RequestTimeoutError
      puts 'Timeout when fetching feed ' + self.id.to_s
      return
    end

    return if feed.is_a? Integer

    # return if feed has not changed. the second test is there because
    # feeds appear in reverse order when they all have the same date
    if self.entries.first and feed.entries.first
      if (feed.entries.first.url == self.entries.first.url) ||
         (feed.entries.first.url == self.entries.last.url)
        return
      end
    end

    self.update_attributes(title:      feed.title,
                           site_url:   feed.url || feed.feed_url)

    entries = feed.entries[0..5]
    self.entries.destroy_all
    entries.each do |entry|
      description = entry.content || entry.summary
      self.entries.create(title:       entry.title,
                          description: sanitize(strip_tags(description)),
                          pub_date:    find_pub_date(entry.published),
                          image:       find_image(entry, description),
                          url:         entry.url)
    end
  end

  private

  def find_pub_date(date)
    if date.nil? or date > Time.zone.now
      Time.zone.now
    else
      date
    end
  end

  def find_image(entry, description)
    if filter_image(entry.image)
      return entry.image
    else
      return find_image_from_desc(description)
    end
  end

  def find_image_from_desc(description)
    doc = Nokogiri::HTML description
    doc.css('img').each do |img|
      if actual_image = filter_image(img.attributes['src'].value)
        return actual_image
      end
    end
    return nil
  end

  def filter_image(img)
    if img.nil? || img.blank?
      return nil
    end

    if img.start_with? '//'
      img = "http:" + img
    elsif img.start_with? '/'
      parse = URI.parse(self.feed_url)
      img = parse.scheme + '://' + parse.host + img
    elsif img.start_with? '../'
      parse = URI.parse(self.url)
      img = parse.scheme + '://' + parse.host + img[2..-1]
    end

    # discard silly images
    if img.include? 'feedburner' or
      img.include? 'pml.png' or
      img.include? '.gif' or
      img.include? '.tiff' or
      img.include? 'rc.img' or
      img.include? 'mf.gif' or
      img.include? 'mercola.com/aggbug.aspx' or
      img.include? 'ptq.gif' or
      img.include? 'twitter16.png' or
      img.include? 'sethsblog' or
      img.include? 'assets.feedblitz.com/i/' or
      img.include? '/heads/' or
      img.include? '/share/' or
      img.include? 'smile.png' or
      img.include? 'application-pdf.png' or
      img.include? 'gif;base64' or
      img.include? 'abrirpdf.png' or
      img.include? 'gravatar.com/avatar' or
      img.include? 'nojs.php' or
      img.include? 'icon_' or
      img.include? 'gplus-16.png' or
      img.include? 'logo' or
      img.include? 'webkit-fake-url' or
      img.include? 'usatoday-newstopstories' or
      img.include? 'a2.img' or
      img.include? 'ach.img' or
      img.include? '/comments/' or
      img.include? 'a2t.img' or
      img.include? 'a2t2.img' or
      img.include? 'subscribe.jpg' or
      img.include? 'transparent.png' or
      img.include? '.mp3' or
      img.include? '.mp4' or
      img.include? '.pdf' or
      img.include? '.ogv'
      return nil
    else
      return img
    end
end

end
