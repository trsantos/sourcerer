class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed
  has_many :entries, through: :feed

  before_create :set_visited_at

  validates :user_id, presence: true
  validates :feed_id, presence: true

  private

  def set_visited_at
    self.visited_at = 100.years.ago
  end
end
