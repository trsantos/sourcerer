desc 'This task updates ALL feeds in database'
task update_all_feeds: :environment do
#  Feed.update_all # if Time.current.hour.modulo(2) == 0
end
