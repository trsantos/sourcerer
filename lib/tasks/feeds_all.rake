desc 'This task updates ALL feeds in database'
task update_all_feeds: :environment do
  Feed.all.each do |f|
    # wait 3 hours between updates
    f.delay.update if f.updated_at > 2.hours.ago
  end
end
