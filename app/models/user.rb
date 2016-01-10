class User < ActiveRecord::Base
  include ApplicationHelper

  has_and_belongs_to_many :topics
  has_many :subscriptions, dependent: :delete_all
  has_many :feeds, through: :subscriptions
  has_many :entries, through: :feeds

  attr_accessor :remember_token, :reset_token
  before_save :downcase_email
  after_create :set_expiration_date

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 6 }, allow_blank: true

  # Returns the hash digest of the given string
  def self.digest(string)
    if ActiveModel::SecurePassword.min_cost
      cost = BCrypt::Engine::MIN_COST
    else
      cost = BCrypt::Engine.cost
    end
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def self.new_token
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

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.current)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def follow(feed, options = {})
    return if following? feed
    subscriptions.create(feed_id: feed.id,
                         topic: options[:topic])
  end

  def unfollow(feed)
    s = subscriptions.find_by(feed_id: feed.id)
    s.destroy if s
  end

  def following?(feed)
    feeds.include?(feed)
  end

  def follow_topic(topic)
    topics.append topic unless topics.include? topic
    topic.feeds.each do |f|
      follow(f, topic: topic)
    end
  end

  def unfollow_topic(topic)
    topics.delete topic
    topic.feeds.each do |f|
      s = subscriptions.find_by(feed_id: f.id)
      s.destroy if s && (s.topic == topic)
    end
  end

  def following_topic?(topic)
    topics.include?(topic)
  end

  def next_feed
    sub = updated_sub || random_sub
    sub.feed
  rescue
    self
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  def set_expiration_date
    update_attribute(:expiration_date, 2.weeks.from_now)
  end

  def updated_sub
    subscriptions.where(updated: true)
      .order(starred: :desc, visited_at: :asc).first
  end

  def random_sub
    subscriptions.order('RANDOM()').take
  end
end
