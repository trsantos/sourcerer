require 'timeout'

desc "This task updates all feeds in the database regularly"
task :update_feeds => :environment do
  puts "Updating feeds..."
  Feed.all.each do |f|
    puts "Updating feed #{f.id}: #{f.title}"
    begin
      Timeout.timeout(10) { f.update }
    rescue Timeout::Error => e
      puts "Feed " + f.id.to_s + " took too long to update."
    end
  end
  puts "Done."
end
