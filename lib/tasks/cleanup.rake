desc "This task destroys all feeds that have no users"
task :cleanup_feeds => :environment do
  Feed.all.each do |f|
    f.destroy if f.users.empty?
  end
end
