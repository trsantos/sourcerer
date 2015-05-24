class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def self.visit_interval
    # This should be configurable by the user
    Time.zone.now
  end

  def updated?
    if self.visited_at.nil?
      return true
    end
    begin
      if (self.visited_at < Subscription.visit_interval) and
        (self.feed.entries.first.pub_date > self.visited_at)
        return true
      end
    rescue
    end
    return false
  end

end
