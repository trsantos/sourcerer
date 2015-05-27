desc "Mark subscriptions as updated (or not)"
task :update_subscriptions_status => :environment do
  Subscription.all.each do |s|
    s.update_attribute(:updated, s.updated?)
  end
end
