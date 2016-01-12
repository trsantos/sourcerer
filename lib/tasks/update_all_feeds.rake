desc 'Update ALL feeds in database'
task update_all_feeds: :environment do
  Feed.update_all_feeds
end
