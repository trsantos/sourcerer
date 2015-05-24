require 'timeout'

class UpdateFeeds
  def perform
    Feed.all.each do |f|
      f.update
    end
  end
end

desc "This task updates all feeds in the database regularly"
task :update_feeds => :environment do
  puts "Updating feeds..."
  Delayed::Job.enqueue UpdateFeeds.new
  puts "Done."
end
