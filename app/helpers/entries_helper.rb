module EntriesHelper
  def old?(entry, sub = nil)
    begin
      if sub.nil?
        sub = current_user.subscriptions.find_by(feed_id: entry.feed.id)
      end
      return true if entry.pub_date < sub.visited_at
      return true if entry.created_at < sub.visited_at
    rescue
    end
    return false
  end
end
