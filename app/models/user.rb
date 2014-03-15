require 'digest/sha2'
class User < ActiveRecord::Base

  has_many :relationships, foreign_key: :user_id
  has_many :rides, through: :relationships

  has_many :ratings

  before_create :create_remember_token, :generate_api_key
  before_save { self.email = email.downcase }
  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 20}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, length: {minimum: 6}

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.generate_api_key(user)
    user.update_attribute(:api_key, SecureRandom.urlsafe_base64)
  end

  def to_s
    "#{self.first_name} #{self.last_name}, #{self.password_digest}"
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

  def generate_api_key
    self.api_key = SecureRandom.urlsafe_base64
  end


end
