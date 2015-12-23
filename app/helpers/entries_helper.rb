module EntriesHelper
  def old?(entry, last_visit)
    return if Rails.env.development?
    entry.created_at < last_visit
  rescue
    false
  end
end
