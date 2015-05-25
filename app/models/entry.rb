class Entry < ActiveRecord::Base
  belongs_to :feed
  default_scope -> { order(pub_date: :desc) }
  validates :feed_id, presence: true
end
