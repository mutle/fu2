class Post < ActiveRecord::Base
  belongs_to :channel
  belongs_to :user
  has_many :faves

  scope :first_channel_post, proc { |c| includes(:user).where(:channel_id => c.id).order("created_at DESC").limit(1) }
  scope :before, proc { |c, id| includes(:user).where("channel_id = :channel_id AND id < :id", :channel_id => c.id, :id => id) }
  scope :since, proc { |c, id| includes(:user).where("channel_id = :channel_id AND id > :id", :channel_id => c.id, :id => id) }
  scope :updated_since, proc { |c, d| includes(:user).where("channel_id = :channel_id AND updated_at > :d", :channel_id => c.id, :d => (d + 1)).order("id") }
  scope :most_recent, proc { order("created_at DESC").limit(1) }
  scope :with_ids, proc { |ids| where(id: ids) }

  after_create :update_channel_last_post
  after_create :scan_for_mentions
  after_create :process_fubot_message

  after_create :update_index
  after_update :update_index
  before_destroy :remove_index

  attr_accessor :read

  class << self
    def indexed_type
      "post"
    end

    def index_definition
      {
        settings: {},
        mappings: {
          indexed_type => {
            properties: {
              body: { type: 'string', analyze: 'standard' },
              created: { type: 'date', index: 'not_analyzed' },
              user: { type: 'string', analyze: 'standard' },
              faves: { type: 'integer', index: 'not_analyzed' },
              site_id: { type: 'integer', index: 'not_analyzed' }
            }
          }
        }
      }
    end
  end

  def to_indexed_json
    return {} if !channel || !channel.default_read?
    {
      :_id => id,
      :_type => self.class.indexed_type,
      :body => body,
      :created => created_at,
      :user => (user.login rescue ''),
      :faves => faves.size,
      :faver => faves.map { |fave| fave.user.login }.join(" "),
      :mention => mentioned_users.join(" "),
      :site_id => 1
    }
  end

  def update_channel_last_post
    if channel
      channel.update_attribute(:last_post_date, created_at)
    end
    true
  end

  def scan_for_mentions
    mentioned = {}
    body.scan Channel::MentionPattern do |mention|
      login = mention[0]
      if u = User.where("LOWER(login) = LOWER(:login)", :login => login).first
        next if mentioned[u.id]
        mentioned[u.id] = true
        channel.add_mention(u)
        Notification.mention(user, u, channel, self)
        Live.notification_counters(u)
      end
    end
    true
  end

  def mentions?(user)
    body.scan Channel::MentionPattern do |mention|
      login = mention[0]
      return true if login.downcase == user.login.downcase
    end
    false
  end

  def mentioned_users
    users = []
    body.scan Channel::MentionPattern do |mention|
      users << mention[0]
    end
    users
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

  def faved_by?(user, faves=nil)
    if faves
      faves.select { |f| f.user_id == user.id }.any?
    else
      faves_for(user).count > 0
    end
  end

  def fave(user)
    faves.create :user_id => user.id
  end

  def unfave(user)
    faves_for(user).destroy_all
  end

  # def as_json(*args)
  #   {:body => body, :created_at => created_at, :id => id, :updated_at => updated_at, :user_id => user_id, :user_name => user.login, :channel_id => channel_id, :channel_title => channel.title, :markdown => markdown?, :html_body => html_body}
  # end

  def process_fubot_message
    if Rails.env.development?
      process_fubot_message!
    else
      Resque.enqueue(FubotJob, :post, self.id) if self.user_id != User.fubot.id
    end
  end

  def process_fubot_message!
    return if self.user_id == User.fubot.id
    Fubot.new(self, user).call(self.body)
  end

  def send_fubot_message(m)
    return if !m
    channel.posts.create(:body => m.text.to_s, :user => User.fubot, :markdown => true)
  end

  def html_body
    result = markdown? ? RenderPipeline.markdown(body, id) : RenderPipeline.simple(body, id)
    result.html_safe
  end

  def update_index
    Search.update("posts", id)
  end

  def remove_index
    Search.remove("posts", id)
  end

end
