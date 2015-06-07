module EntriesHelper
  def old? entry
    # Disable this old entries stuff for now
    s = current_user.subscriptions.find_by(feed_id: entry.feed_id)
    if !s.nil? and !s.visited_at.nil? and s.visited_at > entry.created_at
      return "old"
    end
    return ""
  end
end
