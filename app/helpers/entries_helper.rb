module EntriesHelper
  def old?(entry, last_visit)
    entry.created_at < last_visit
  rescue
    false
  end
end
