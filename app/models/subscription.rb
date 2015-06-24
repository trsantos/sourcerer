class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true
end
