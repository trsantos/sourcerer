module EntriesHelper
  def old?(entry, subscription)
    return true if entry.created_at < subscription.visited_at
    false
  rescue
    false
  end
end
