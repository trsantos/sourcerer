class FeedUpdateJob < ActiveJob::Base
  queue_as :low

  def perform(feed)
    feed.update
    ActiveRecord::Base.connection.close
  end
end
