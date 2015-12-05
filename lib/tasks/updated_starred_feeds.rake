desc 'Update feeds starred by at least one user'
task update_starred_feeds: :environment do
  if Time.current.hour.modulo(3) == 0
    Subscription.select(:feed_id).where(starred: true).distinct.each do |s|
      Feed.find(s.feed_id).delay.update
    end
  end
end
