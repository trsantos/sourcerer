class Entry < ActiveRecord::Base
  belongs_to :feed
  default_scope -> { order(created_at: :desc) }
  validates :feed_id, presence: true
end
