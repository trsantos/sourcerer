desc 'Mark all subscriptions as updated (for local development)'
task subscriptions: :environment do
  Subscription.update_all updated: true
end
