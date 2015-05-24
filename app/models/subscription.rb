class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def updated?
    return true if self.visited_at.nil?

    begin
      # true if the subscription is starred OR lastest visit was before visit_interval
      #  AND if the lastest item is newer than the latest visit
      return true if (self.starred? or (Subscription.visit_interval > self.visited_at)) and
        self.feed.entries.first.pub_date > self.visited_at
    rescue
    end

    return false
  end

  def self.visit_interval
    8.hours.ago
  end
end
