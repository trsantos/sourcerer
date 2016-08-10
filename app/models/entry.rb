class Entry < ApplicationRecord
  belongs_to :feed

  validates :feed_id, presence: true
end
