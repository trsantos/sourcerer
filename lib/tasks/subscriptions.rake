desc 'Mark all subscriptions as updated (for local development)'
task subscriptions: :environment do
  Subscription.all.each do |s|
    s.update_attribute :updated, true
  end
end
