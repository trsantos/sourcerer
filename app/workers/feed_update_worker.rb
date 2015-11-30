class FeedUpdateWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(id)
    Feedjira::Feed.fetch_and_parse Feed.find(id).feed_url
#    Feed.find(id).update
  end
end
