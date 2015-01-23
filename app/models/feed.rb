class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  # has_many :subscriptions, dependent: :destroy
  # has_many :users, through: :subscriptions
  has_many :entries, dependent: :destroy
  
  validates :feed_url, presence: true, uniqueness: true

  def update
    # wait 2 hours between updates
    return if self.updated_at > 2.hour.ago and self.entries.count > 0

    Feedjira::Feed.add_common_feed_entry_element("enclosure",
                                                 :value => :url,
                                                 :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:thumbnail",
                                                 :value => :url,
                                                 :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:content",
                                                 :value => :url,
                                                 :as => :image)
    fj_feed = Feedjira::Feed.fetch_and_parse self.feed_url

    # stop if feed coudn't be fetched
    return if fj_feed.is_a? Integer

    # update feed itself
    self.title = fj_feed.title
    self.site_url = fj_feed.url

    # return if feed has not changed entries
    # an ugly hack for HN, Hoover and pg
    return if self.entries.last and fj_feed.entries.first and (fj_feed.entries.first.url == self.entries.last.url)

    # update entries
    entries = fj_feed.entries
    # entries = fj_feed.entries.sort_by { |e| find_pub_date(e.published) }.reverse
    self.entries.destroy_all
    4.times do |n|
      if entries[n]
        description = entries[n].content || entries[n].summary
        self.entries.create(title:       entries[n].title,
                            description: sanitize(strip_tags(description)),
                            pub_date:    find_pub_date(entries[n].published),
                            image:       find_image(description) || entries[n].image,
                            url:         entries[n].url)
      end
    end

    # mark feed as updated
    self.updated_at = Time.zone.now
    self.save
  end

  private

  def find_pub_date(date)
    if date.nil? or date > Time.zone.now
      Time.zone.now
    else
      date
    end
  end

  def find_image(description)
    doc = Nokogiri::HTML description
    img = doc.css('img').first
    if img
      value = img.attributes['src'].value
      # this should use a regex
      if value.first == '/' and value[1] != '/'
        parse = URI.parse(self.feed_url)
        value = parse.scheme + '://' + parse.host + value
      end
      # hack to increase size of Stossel's images
      if value.include? "http://a57.foxnews.com/media.foxbusiness.com"
        value.sub!('121/68', '640/360')
      end
      unless value.include? "feedburner" or
            value.include? "pml.png" or
            value.include? "mf.gif"
        return value
      end
    end
    return nil
  end
end
