module EntriesHelper
  def old_entry? entry
    if logged_in?
      s = current_user.subscriptions.find_by(feed_id: entry.feed_id)
      if !s.nil? and !s.visited_at.nil? and s.visited_at > entry.pub_date
        return true
      end
    end
    return false
  end
end
