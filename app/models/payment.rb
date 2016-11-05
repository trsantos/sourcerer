class Payment < ApplicationRecord
  belongs_to :user

  def self.price
    20
  end

  def self.trial_duration
    30.days
  end

  def self.feed_limit
    100
  end
end
