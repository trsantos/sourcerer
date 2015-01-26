class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  # has_many :subscriptions, dependent: :destroy
  # has_many :users, through: :subscriptions
  has_many :entries, dependent: :destroy
  
  validates :feed_url, presence: true, uniqueness: true

  def update
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

    return if fj_feed.is_a? Integer

    self.title = fj_feed.title
    self.site_url = fj_feed.url

    # feed has not changed entries. an ugly hack for HN, Hoover and pg
    return if self.entries.last and fj_feed.entries.first and (fj_feed.entries.first.url == self.entries.last.url)

    entries = fj_feed.entries
    self.entries.destroy_all
    4.times do |n|
      if entries[n]
        description = entries[n].content || entries[n].summary
        self.entries.create(title:       entries[n].title,
                            description: sanitize(strip_tags(description)),
                            pub_date:    find_pub_date(entries[n].published),
                            image:       process_image(entries[n].image || find_image_from_desc(description), :desc) || process_image(find_og_image(entries[n].url), :og),
                            url:         entries[n].url)
      end
    end

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

  def find_og_image(url)
    ENV['SSL_CERT_FILE'] = "/home/thiago/cacert.pem"
    if url.include? "bbc.co.uk"
      url = url[0..url.index('#')-1]
    end
    begin
      doc = Nokogiri::HTML(open(URI::escape(url.strip), :allow_redirections => :safe))
    rescue OpenURI::HTTPError
      return nil
    end
    image = doc.css("meta[property='og:image']").first
    if image
      return image.attributes['content'].value
    else
      return nil
    end
  end

  def find_image_from_desc(description)
    doc = Nokogiri::HTML description
    img = doc.css('img').first
    if img
      return img.attributes['src'].value
    end
    return nil
  end

  def process_image(img, from = :desc)
    if img
      if img.blank?
        return nil
      end

      # force open graph image
      if (from == :desc) && (img.include? "bbcimg.co.uk")
        return nil
      end

      if img.start_with? '//'
        img = "http:" + img
      elsif img.start_with? '/'
        parse = URI.parse(self.feed_url)
        img = parse.scheme + '://' + parse.host + img
      end

      # hacks to increase some images
      if img.include? "media.foxbusiness.com"
        img.sub!('121/68', '640/360')
      elsif img.include? "global.fncstatic.com"
        img.sub!('60/60', '640/360')
      elsif img.include? "uefa.com"
        img.sub!('s5', 's2')
      elsif img.include? "s2.glbimg.com"
        img = "http://" + img[img.index("s.glbim")..-1]
      elsif img.include? "gsmarena.com"
        img = get_gsmarena_image(img)
      elsif img.include? "goal.com"
        img.sub!('thumb', 'heroa')
      elsif img.include? "info.abril"
        img.sub!('icone', '')
      elsif img.include? "phys.org"
        img.sub!('csz/news/tmb', 'gfx/news')
      elsif img.include? "theatlantic.com"
        img.sub!('thumb', 'lead')
      elsif img.include? "mtvnimages.com"
        img.sub!('width=150&height=150', 'width=640&height=360')
      elsif img.include? "fifa.com"
        img.sub!('small', 'full-lnd')
      elsif img.include? "graphics8.nytimes.com"
        img.sub!('moth', 'master675')
      elsif img.include? "kotaku.com.br" or img.include? "trivela.uol.com.br"
        img.sub!('-205x115', '')
      elsif img.include? "xda-developers.com"
        img.sub!('-150x150', '')
      elsif img.include? "gizmodo.uol.com"
        img.sub!('-320x180', '')
      elsif img.include? "assets.rollingstone.com"
        img.sub!('small_square', 'large_rect')
        img.sub!('100x100', '1401x788')
      end

      # discard some silly images
      unless img.include? 'feedburner' or
            img.include? 'pml.png' or
            img.include? 'mf.gif' or
            img.include? 'fsdn' or
            img.include? 'pixel.wp' or
            img.include? 'gravatar' or
            img.include? 'default-thumbnail' or
            img.include? 'icon308px.png' or
            img.include? '48x48/facebook.png' or
            img.include? 'twitter16.png' or
            img.include? 'uol-jogos-600px.jpg' or
            img.include? 'gif;base64' or
            img.include? 'icon_' or
            img.include? 'valor-big' or
            img.include? 'home_pensmall' or
            img.include? 'gv_og_logo' or
            img.include? 'outbrain-place-holder' or
            img.include? 'ITworld-logo300x300' or
            img.include? 'og-ft-logo-large' or
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
