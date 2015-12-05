desc 'Update feeds starred by at least one user'
task update_starred_feeds: :environment do
  # The second condition is there because of update_all_feeds task running time
  current_hour = Time.current.hour
  if current_hour.modulo(2) == 0 && current_hour != 2
    Subscription.select(:feed_id).where(starred: true).distinct.each do |s|
      Feed.find(s.feed_id).delay.update
    end
  end
end
