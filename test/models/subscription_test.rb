require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  def setup
    @subscription = Subscription.new(user_id: 1, feed_id: 1)
  end

  test "should be valid" do
    assert @subscription.valid?
  end

  test "should require a user_id" do
    @subscription.user_id = nil
    assert_not @subscription.valid?
  end

  test "should require a feed_id" do
    @subscription.feed_id = nil
    assert_not @subscription.valid?
  end
end
