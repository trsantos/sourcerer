class FeedUpdateWorker
  include Sidekiq::Worker
  # sidekiq_options retry: false

  def perform(id)
    Feed.find(id).update
  end
end
