desc "This task updates ALL feeds from database"
task :update_all_feeds => :environment do
  Feed.all.each do |f|
    f.delay.update
  end
end