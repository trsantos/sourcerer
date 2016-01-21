class FeedUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(feed)
    feed.update
    ActiveRecord::Base.connection.close
  end
end
