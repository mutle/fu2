class Post < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :channel
  belongs_to :user
  has_many :faves

  scope :first_channel_post, proc { |c| includes(:user).where(:channel_id => c.id).order("created_at DESC").limit(1) }
  scope :since, proc { |c, id| includes(:user).where("channel_id = :channel_id AND id > :id", :channel_id => c.id, :id => id).order("id") }
  scope :most_recent, order("created_at DESC").limit(1)

  after_create :update_channel_last_post
  after_create :scan_for_mentions

  # before_create :set_markdown
  # before_update :set_markdown

  index_name "posts-#{Rails.env}"

  mapping do
    indexes :_id, :index => :not_analyzed
    indexes :body, :analyzer => 'snowball'
    indexes :created_at, :type => 'date', :index => :not_analyzed
  end

  # define_index do
  #   indexes body
  #   has channel(:default_read)
  #   where sanitize_sql(['default_read', true])
  # end

  def to_indexed_json
    return {}.to_json if !channel || !channel.default_read?
    {
      :_id => id,
      :body => body,
      :created_at => created_at
    }.to_json
  end

  def update_channel_last_post
    channel.update_attribute(:last_post, created_at) if channel
  end

  def scan_for_mentions
    body.scan Channel::MentionPattern do |mention|
      login = mention[0]
      if u = User.where("LOWER(login) = LOWER(:login)", :login => login).first
        channel.add_mention(u)
        Notification.mention(user, u, channel, self)
      end
    end
  end

  def mentions?(user)
    body.scan Channel::MentionPattern do |mention|
      login = mention[0]
      return true if login.downcase == user.login.downcase
    end
    false
  end

  def set_markdown
    self.markdown = user.markdown?
  end

  def can_read?(user)
    channel.can_read?(user)
  end

  def faves_for(user)
     faves.where(:user_id => user.id)
  end

  def faved_by?(user)
    faves_for(user).count > 0
  end

  def fave(user)
    faves.create :user_id => user.id
  end

  def unfave(user)
    faves_for(user).destroy_all
  end

  def as_json(*args)
    {:body => body, :created_at => created_at, :id => id, :updated_at => updated_at, :user_id => user_id, :user_name => user.login, :channel_id => channel_id, :channel_title => channel.title, :markdown => markdown?}
  end

end
