desc 'Mark all subscriptions as updated (for local development)'
task subscriptions: :environment do
  Subscription.find_each do |s|
    s.update_attribute :updated, true
  end
end
