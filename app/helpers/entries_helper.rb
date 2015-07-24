module EntriesHelper
  def old?(entry, sub = nil)
    sub = current_user.subscriptions.find_by(feed_id: entry.feed.id) if sub.nil?
    return true if entry.pub_date < sub.visited_at
    return true if entry.created_at < sub.visited_at
    false
  rescue
    false
  end
end
