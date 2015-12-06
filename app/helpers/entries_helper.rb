module EntriesHelper
  def old?(entry, last_visit)
    entry.pub_date < last_visit
  rescue
    false
  end
end
