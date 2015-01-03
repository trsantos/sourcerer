require 'test_helper'

class FeedDisplayTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @feed = feeds(:one)
  end

  # this test is sooo incomplete
  test "feed display" do
    get feed_path(@feed)
    assert_template 'feeds/show'
    assert_select 'title', full_title(@feed.title)
    assert_equal @feed.entries.count, 5
    assert_select 'header.feed-header'
    assert_select 'div.row'
    assert_select 'article'
  end
end
