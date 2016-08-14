desc 'Delete unused feeds and inactive users'
task cleanup_feeds: :environment do
  Feed.find_each do |f|
    f.destroy if f.users.empty? && f.created_at < 1.week.ago
  end
  User.find_each do |u|
    if u.updated_at < 1.month.ago && user.expiration_date < Time.current
      u.destroy
    end
  end
end
