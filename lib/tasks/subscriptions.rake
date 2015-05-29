desc "This task changes all subscriptions updated_at attribute"
task :randomize_subscriptions => :environment do
  Subscription.all.shuffle.each do |s|
    s.update_attribute(:updated_at, Time.zone.now)
  end
end
