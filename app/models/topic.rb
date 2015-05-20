class Topic < ActiveRecord::Base
  has_many :topic_subscriptions
  has_many :users, through: :topic_subscriptions
end
