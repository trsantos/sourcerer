desc "This task updates all feeds in the database"
task :update_feeds => :environment do
  Feed.all.each do |f|
    f.delay.update
  end
end
