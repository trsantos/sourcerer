class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def updated?
    return true if self.visited_at.nil?

    begin
      return true if self.feed.entries.first.pub_date > self.visited_at
    rescue
    end

    return false
  end

end
