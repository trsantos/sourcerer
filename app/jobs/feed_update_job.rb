class FeedUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(feed_id)
    Feed.find(feed_id).update
    ActiveRecord::Base.connection.close
  end
end
