module EntriesHelper
  def old?(entry)
    begin
      return true if entry.pub_date < current_user.subscriptions.find_by(feed_id: entry.feed.id).visited_at
    rescue
    end
    return false
  end
end
