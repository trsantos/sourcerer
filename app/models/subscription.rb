class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def self.visit_interval
    0.hour.ago
  end

  def updated?
    # if a feed has been visited but, at a later date, it is fetched and contains no
    # entries, there will be no pud_date to check and we will consider it as not
    # updated. this is what the check for the first item does
    if self.visited_at.nil?
      return true
    end
    begin
      if self.visited_at < Subscription.visit_interval
        if self.feed.entries.first.pub_date > self.visited_at
          return true
        end
      end
    rescue
    end
    return false
  end

end
