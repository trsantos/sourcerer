require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  def setup
    @feed = feeds(:one)
    @entry = @feed.entries.build
  end
  
  test "feed id should be present" do
    @entry.feed_id = nil
    assert_not @entry.valid?
  end

  test "order should be most recent first (by pub_date)" do
    # entries(:one) contains the most recent entry
    assert_equal Entry.first, entries(:one)
  end
end
