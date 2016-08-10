class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed
  has_many :entries, through: :feed

  validates :user_id, presence: true
  validates :feed_id, presence: true
end
