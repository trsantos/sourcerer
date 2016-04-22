desc 'Update ALL feeds in database'
task update_all_feeds: :environment do
  if (Time.current.hour.modulo 3) == 0
    Feed.update_all_feeds
  end
end
