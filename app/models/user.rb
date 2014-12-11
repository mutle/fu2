require 'digest/sha1'
require 'bcrypt'

class User < ActiveRecord::Base

  serialize :block_users

  scope :with_login, lambda { |login| where("LOWER(login) = LOWER(:login) and activated_at IS NOT NULL", :login => login) }

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  # validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  # validates_format_of       :color, :with => /^(\#([0-9a-fA-F]{6}))?$/

  before_save :encrypt_password

  before_create :make_activation_code
  before_create :set_display_name
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  # attr_accessible :login, :email, :password, :password_confirmation, :color, :display_name, :stylesheet_id, :markdown, :new_features, :avatar_url

  after_create :create_private_channel

  has_many :posts
  has_many :channel_visits
  has_many :uploads

  has_many :messages
  has_many :unread_messages, lambda { where("status = #{Message::STATUS_UNREAD}") }, :class_name => "Message"

  has_many :faves

  belongs_to :stylesheet

  class << self
    def fubot
      find_by_login("fubot")
    end
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save!
  end

  def can_invite?
    id == 1
  end

  def set_display_name
    self.display_name = login
  end

  def private_channel
    Channel.where("user_id = ? AND title = ? AND default_read = ?", id, "#{login}/Mailbox", false).first
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

  def self.all_users
    self.order("LOWER(display_name)").all
  end

  def password
    if password_hash.blank?
      @password ||= ""
    else
      @password ||= BCrypt::Password.new(password_hash)
    end
  end

  def password=(pw)
    length = pw.to_s.size
    if length < 4
      errors.add(:password, " is too short (minimum is 4 characters)")
    elsif length > 40
      errors.add(:password, " is too long (maximum is 40 characters)")
    end

    if pw
      @password = BCrypt::Password.create(pw)
    else
      @password = nil
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = with_login(login).first
    return nil unless u
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    if password_hash.blank?
      crypted_password == encrypt(password)
    else
      self.password == password
    end
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save # (false)
  end

  def create_private_channel
    Channel.create(:title => "#{login}/Mailbox", :user_id => id, :default_read => false, :default_write => true)
  end

  def display_color
    "color: #{color}" unless color.blank?
  end

  def number_unread_messages
    Message.count(:conditions => {:user_id => id, :status => 0})
  end

  def block_user(u)
    self.block_users ||= []
    self.block_users << u.id.to_i
  end

  def enable_api_usage
    if self.api_key.blank?
      self.api_key = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      save
    end
  end

  def as_json(*args)
    {:id => id, :login => login, :display_name => display_name, :display_name_html => RenderPipeline.title(display_name), :display_color => display_color, :avatar_url => avatar_image_url}
  end

  def new_features
    $redis.sismember("users:new_features", id)
  end

  def new_features=(v)
    if !v
      $redis.srem("users:new_features", id)
    else
      $redis.sadd("users:new_features", id)
    end
  end

  def avatar_image_url(size=42)
    if avatar_url.blank?
      gravatar_id = Digest::MD5.hexdigest(email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    else
      avatar_url
    end
  end

  def multi_site?
    id == 1
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.password_hash = password
    end

    def password_required?
      !@password.nil? && (crypted_password.blank? || password_hash.blank?)
    end

    def make_activation_code

      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

end
