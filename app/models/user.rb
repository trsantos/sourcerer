class User < ActiveRecord::Base
  include ApplicationHelper

  has_many :topic_subscriptions, dependent: :destroy
  has_many :topics, through: :topic_subscriptions

  has_many :subscriptions, dependent: :destroy
  has_many :feeds, through: :subscriptions

  has_one  :next_feed, dependent: :destroy
  
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 6 }, allow_blank: true

  # Returns the hash digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Follow a feed. Last arg should be a hash
  def follow(feed, from_topic = false)
    unless following?(feed)
      subscriptions.create(feed_id: feed.id, from_topic: from_topic)
    end
  end

  # Unfollow a feed
  def unfollow(feed)
    s = subscriptions.find_by(feed_id: feed.id)
    if s
      s.destroy
    end
  end

  # True if current user is following the given feed
  def following?(feed)
    feeds.include?(feed)
  end

  def follow_topic(topic)
    self.topics += [topic]
    get_feeds(topic).each do |url|
      follow(Feed.find_or_create_by(feed_url: url), true)
    end
    #topic.feeds.each do |f|
    #  follow(f)
    #end
  end

  def unfollow_topic(topic)
    get_feeds(topic).each do |url|
      f = Feed.find_or_create_by(feed_url: url)
      s = self.subscriptions.find_by(feed_id: f.id)
      if s and s.from_topic
        unfollow(f)
      end
    end
  end

  def following_topic?(topic)
    return topics.include?(topic)
  end

  def set_next_feed
    subs = self.subscriptions.order(starred: :desc, updated_at: :desc)
    next_sub = nil
    subs.each do |s|
      if s.updated?
        if s.starred? or s.visited_at.nil? or s.visited_at < 1.day.ago
          next_sub = s
        end
        next_sub ||= s
      end
    end
    if next_sub
      NextFeed.create(user_id: self.id, feed_id: next_sub.feed.id)
    end
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end
