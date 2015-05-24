require 'timeout'

desc "This task updates all feeds in the database regularly"
task :update_feeds => :environment do
  puts "Updating feeds..."
  Feed.all.each do |f|
    f.delay.update
  end
  puts "Done."
end
