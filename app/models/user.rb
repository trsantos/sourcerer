class User < ApplicationRecord
  has_secure_password

  has_many :subscriptions, dependent: :delete_all
  has_many :feeds, through: :subscriptions
  has_many :entries, through: :feeds
  has_many :payments

  before_create { generate_token(:auth_token) }
  before_create :set_expiration_date
  before_save :downcase_email

  validates :name,  presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, allow_blank: true

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.current
    save!
    UserMailer.password_reset(self).deliver_later(queue: :default)
  end

  def unfollow(feed)
    s = subscriptions.find_by(feed_id: feed.id)
    s.destroy if s
  end

  def following?(feed)
    feeds.include?(feed)
  end

  def next_feed
    if subscriptions.any?
      sub = random_updated_sub || random_sub
      sub.feed
    else
      self
    end
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.strip.downcase
  end

  def set_expiration_date
    self.expiration_date = Payment.trial_duration.from_now
  end

  def updated_sub
    subscriptions
      .where(updated: true)
      .order(starred: :desc, visited_at: :asc).first
  end

  def random_updated_sub
    subscriptions
      .where(updated: true)
      .order(starred: :desc).order('RANDOM()').take
  end

  def random_sub
    subscriptions.order('RANDOM()').take
  end
end
