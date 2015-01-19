class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def updated?
    return self.visited_at.nil? || (self.feed.entries.first.pub_date > self.visited_at)
  end
end
