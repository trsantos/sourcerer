desc 'Destroy all feeds that have no users'
task cleanup_feeds: :environment do
  Feed.find_each do |f|
    f.destroy if f.users.empty? && f.created_at < 1.week.ago
  end
end
