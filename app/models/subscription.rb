class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def updated?
    return true if self.visited_at.nil?

    begin
      # true if the lastest item is newer than the latest visit AND
      #      if the lastest visit was before visit_interval
      return true if self.feed.entries.first.pub_date > self.visited_at and
        Subscription.visit_interval > self.visited_at
    rescue
    end

    return false
  end

  def self.visit_interval
    4.hours.ago
  end
end
