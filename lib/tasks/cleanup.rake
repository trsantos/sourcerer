desc 'Delete unused feeds'
task cleanup: :environment do
  Feed.find_each do |f|
    f.destroy if f.users.empty? && f.created_at < 1.week.ago && !f.top_site?
  end
end
