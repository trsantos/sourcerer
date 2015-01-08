require 'test_helper'

class FeedTest < ActiveSupport::TestCase
  def setup
    # feeds(:two) has no entries
    @feed = feeds(:two)
  end

  test "should be valid" do
    assert @feed.valid?
  end

  test "feed_url should be present" do
    @feed.feed_url = nil
    assert_not @feed.valid?
  end

  test "feed_url should not be blank" do
    @feed.feed_url = "     "
    assert_not @feed.valid?
  end

  test "associated entries should be destroyed" do
    @feed.save
    @feed.entries.create!(title: "Hello")
    assert_difference 'Entry.count', -1 do
      @feed.destroy
    end
  end

  test "user should follow and unfollow a feed" do
    user = users(:thiago)
    assert_not user.following?(@feed)
    user.follow(@feed)
    assert user.following?(@feed)
    user.unfollow(@feed)
    assert_not user.following?(@feed)
  end
end
