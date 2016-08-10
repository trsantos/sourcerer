class FeedUpdateJob < ApplicationJob
  queue_as :low

  def perform(feed)
    feed.update
    ActiveRecord::Base.connection.close
  rescue
    # TODO: log an error message if the update fails
    nil
  end
end
