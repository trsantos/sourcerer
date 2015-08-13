desc "This task updates ALL feeds in database"
task :update_all_feeds => :environment do
  Feed.all.each do |f|
    f.delay.update if f.entries.empty? || f.updated_at < 1.hour.ago
  end
end
