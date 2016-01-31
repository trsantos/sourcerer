module EntriesHelper
  def old?(entry)
    entry.created_at < @subscription.visited_at
  rescue
    false
  end
end
