desc 'This task updates ALL feeds in database'
task update_all_feeds: :environment do
  Feed.find_each { |f| f.delay(priority: 10).update }
  GC.start
end
