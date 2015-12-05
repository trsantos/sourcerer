desc 'Update ALL feeds in database'
task update_all_feeds: :environment do
  Feed.find_each { |f| f.delay.update }
end
