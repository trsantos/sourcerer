desc 'Delete unused feeds and inactive users'
task cleanup: :environment do
  Feed.find_each do |f|
    f.destroy if f.users.empty? && f.created_at < 1.week.ago && !f.top_site?
  end
  User.find_each do |u|
    if u.updated_at < 1.month.ago && user.expiration_date < Time.current && user.feeds.count > Payment.feed_limit
      u.destroy
    end
  end
end
