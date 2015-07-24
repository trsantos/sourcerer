class Entry < ActiveRecord::Base
  belongs_to :feed
  validates :feed_id, presence: true
  # default_scope { order(pub_date: :desc) }
end
