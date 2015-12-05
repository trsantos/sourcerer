desc 'Update ALL feeds in database'
task update_all_feeds: :environment do
  Feed.find_each { |f| f.delay.update } if Time.current.hour.modulo(3) == 0
end
