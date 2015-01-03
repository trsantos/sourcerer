class Feed < ActiveRecord::Base
  has_many :entries, dependent: :destroy
  validates :feed_url, presence: true, uniqueness: true

  def update
    fj_feed = Feedjira::Feed.fetch_and_parse self.feed_url
    entries = fj_feed.entries
    self.entries.destroy_all
    4.times do |n|
      if entries[n]
        self.entries.create(title:       entries[n].title,
                            description: entries[n].content || entries[n].summary,
                            pub_date:    entries[n].published || Time.zone.now,
                            url:         entries[n].url)
      end
    end
  end
end
