module EntriesHelper
  def old_entry? entry
    # Disable this old entries stuff for now
    return false
    if logged_in?
      s = current_user.subscriptions.find_by(feed_id: entry.feed_id)
      if !s.nil? and !s.visited_at.nil? and s.visited_at > entry.pub_date
        return true
      end
    end
    return false
  end
end
