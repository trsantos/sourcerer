class Topic < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :subscriptions
  has_many :feeds
end
