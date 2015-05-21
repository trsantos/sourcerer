class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def updated?
    # if a feed has been visited but, at a later date, it is fetched and contains no
    # entries, there will be no pud_date to check and we will consider it as not
    # updated. this is what the check for the first item does
    return self.visited_at.nil? ||
           ((self.visited_at < 5.hours.ago) &&
            (self.feed.entries.first && (self.feed.entries.first.pub_date > self.visited_at)))
  end

  def self.update_interval
    2.hours.ago
  end

  def self.visit_interval
    5.hours.ago
  end
end
