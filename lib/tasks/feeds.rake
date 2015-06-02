desc "This task updates feeds subscribed by at least one user"
task :update_feeds => :environment do
  Feed.all.each do |f|
    f.delay.update if f.users.any?
  end
end
