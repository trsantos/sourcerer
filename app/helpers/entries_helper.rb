module EntriesHelper
  def old? entry
    s = current_user.subscriptions.find_by(feed_id: entry.feed_id)
    return !s.nil? && !s.visited_at.nil? && s.visited_at > entry.pub_date
  end
end
