class FeedUpdateWorker
  include Sidekiq::Worker

  def perform(id)
    Feedjira::Feed.fetch_and_parse Feed.find(id).feed_url
#    Feed.find(id).update
  end
end
