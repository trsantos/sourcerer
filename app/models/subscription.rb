class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def updated?
    return false if self.feed.entries.empty?

    return true if self.visited_at.nil?

    begin
      self.feed.entries.each do |e|
        return true if e.pub_date > self.visited_at
      end
    rescue
    end

    return false
  end
end
