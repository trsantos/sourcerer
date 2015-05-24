desc "This task changes all subscriptions updated_at attribute"
task :update_subscriptions => :environment do
  puts "Updating subscriptions dates..."
  Subscription.all.shuffle.each do |s|
    s.update_attribute(:updated_at, Time.zone.now)
  end
  puts "Done."
end
