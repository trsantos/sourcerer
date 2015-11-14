desc 'This task updates ALL feeds in database'
task update_all_feeds: :environment do
  if Time.current.hour.modulo(4) == 0
    Feed.all.each do |f|
      f.delay.update
    end
  end
end
