class Feed < ActiveRecord::Base
  # has_many :subscriptions, dependent: :destroy
  # has_many :users, through: :subscriptions
  has_many :entries, dependent: :destroy
  
  validates :feed_url, presence: true, uniqueness: true

  def update
    # I don't now if I should make this a controller action...

    # wait 1 hour between updates
    return if self.updated_at > 1.hour.ago and self.entries.count > 0

    fj_feed = Feedjira::Feed.fetch_and_parse self.feed_url

    # stop if feed coudn't be fetched
    return if fj_feed.is_a? Integer

    # update entries
    # entries = fj_feed.entries
    entries = fj_feed.entries.sort_by { |e| e.published }.reverse
    self.entries.destroy_all
    5.times do |n|
      if entries[n]
        self.entries.create(title:       entries[n].title,
                            description: entries[n].content   || entries[n].summary,
                            pub_date:    entries[n].published || Time.zone.now,
                            url:         entries[n].url)
      end
    end

    # mark feed as updated
    self.updated_at = Time.zone.now
    self.save
  end
end
