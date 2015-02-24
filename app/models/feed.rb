class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  # has_many :subscriptions, dependent: :destroy
  # has_many :users, through: :subscriptions
  has_many :entries, dependent: :destroy
  
  validates :feed_url, presence: true, uniqueness: true

  def update
    return if self.updated_at > 2.hour.ago and self.entries.count > 0

    Feedjira::Feed.add_common_feed_entry_element("enclosure", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:thumbnail", :value => :url, :as => :image)
    Feedjira::Feed.add_common_feed_entry_element("media:content", :value => :url, :as => :image)

    feed = Feedjira::Feed.fetch_and_parse self.feed_url

    return if feed.is_a? Integer

    self.update_attribute(:updated_at, Time.zone.now)

    # return if feed has not changed
    # if self.entries.first and feed.entries.first
    #   if (feed.entries.first.url == self.entries.last.url) ||
    #      (feed.entries.first.url == self.entries.first.url)
    #     return
    #   end
    # end

    self.update_attributes(title:    feed.title,
                           site_url: feed.url)

    entries = feed.entries
    self.entries.destroy_all
    4.times do |n|
      if entries[n]
        description = entries[n].content || entries[n].summary
        self.entries.create(title:       entries[n].title,
                            description: sanitize(strip_tags(description)),
                            pub_date:    find_pub_date(entries[n].published),
                            image:       process_image(entries[n].image || find_image_from_desc(description)),
                            url:         entries[n].url)
      end
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

  def find_og_image(url)
    # ENV['SSL_CERT_FILE'] = "/home/thiago/cacert.pem"
    # if url.include? "bbc.co.uk"
    #   url = url[0..url.index('#')-1]
    # end
    begin
#      doc = Nokogiri::HTML(open(URI::escape(url.strip), :allow_redirections => :safe))
      doc = Nokogiri::HTML(open(URI::escape(url.strip)))
    rescue StandardError
      return nil
    end
    image = doc.css("meta[property='og:image']").first
    if image
      img = image.attributes['content'].value
      return img unless img.include? 'logo' or img.include? 'Logo'
    end
    return nil
  end

  def find_image_from_desc(description)
    doc = Nokogiri::HTML description
    img = doc.css('img').first
    if img
      return img.attributes['src'].value
    end
    return nil
  end

  def process_image(img)
    if img
      if img.blank?
        return nil
      end

      if img.start_with? '//'
        img = "http:" + img
      elsif img.start_with? '/'
        parse = URI.parse(self.feed_url)
        img = parse.scheme + '://' + parse.host + img
      end

      # discard some silly images
      unless img.include? 'feedburner' or
            img.include? 'pml.png' or
            img.include? 'blank.gif' or
            img.include? 'mf.gif' or
            img.include? 'mercola.com/aggbug.aspx' or
            img.include? 'ptq.gif' or
            img.include? 'twitter16.png' or
            img.include? 'application-pdf.png' or
            img.include? 'gif;base64' or
            img.include? 'icon_' or
            img.include? '.mp3' or
            img.ends_with? 'ogv' or
            img.ends_with? 'mp4'
        return img
      end
    end
    return nil
  end

  def get_gsmarena_image(img)
    3.times do |n|
      temp = img.sub('thumb.jpg', 'gsmarena_00' + n.to_s + '.jpg')
      url = URI.parse(temp)
      if Net::HTTP.new(url.host, url.port).request_head(url.path).code == "200"
        return temp
      end
    end
    return img
  end
end
