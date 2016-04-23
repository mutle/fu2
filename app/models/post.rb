class Post < ActiveRecord::Base
  include SiteScope

  class Highlighter
    include ActionView::Helpers::TextHelper
  end

  belongs_to :channel
  belongs_to :user
  belongs_to :site
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
  after_create :update_channel_tags
  after_update :update_channel_tags

  after_create :notify_create
  after_update :notify_update
  before_destroy :notify_destroy

  after_create :update_index
  after_update :update_index
  before_destroy :remove_index

  attr_accessor :read, :query

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
      :site_id => site_id
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
    body.scan Channel::MentionPatterns[Channel::UsernamePattern] do |mention|
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
    body.scan Channel::MentionPatterns[Channel::UsernamePattern] do |mention|
      login = mention[0]
      return true if login.downcase == user.login.downcase
    end
    false
  end

  def mentioned_users
    users = []
    body.scan Channel::MentionPatterns[Channel::UsernamePattern] do |mention|
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

  def faves_for(user, emoji="star")
     faves.where(user_id: user.id, emoji: emoji)
  end

  def faved_by?(user, faves=nil, emoji="star")
    if faves
      faves.select { |f| f.user_id == user.id && f.emoji == emoji }.any?
    else
      faves_for(user, emoji).count > 0
    end
  end

  def fave(user, emoji="star")
    faves.create user_id: user.id, emoji: emoji
    Live.post_fave self
  end

  def unfave(user, emoji="star")
    faves_for(user, emoji).destroy_all
    Live.post_unfave self
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
    Fubot.new(self, user, site).call(self.body)
  end

  def send_fubot_message(m)
    return if !m
    channel.posts.create(:body => m.text.to_s, :user => User.fubot, :markdown => true)
  end

  def html_body(current_user=nil)
    text = body
    if query && query["text"]
      text = Highlighter.new.highlight(text, query["text"])
    end
    result = markdown? ? RenderPipeline.markdown(text, id, current_user.try(:login)) : RenderPipeline.simple(text, id, current_user.try(:login))
    result.html_safe
  end

  def update_index
    Search.update("posts", id)
  end

  def remove_index
    Search.remove("posts", id)
  end

  def notify_create
    Live.post_create self
  end

  def notify_update
    Live.post_update self
  end

  def notify_destroy
    Live.post_destroy self
  end

  def update_channel_tags
    if channel
      tags = []
      body.scan Channel::TagPattern do |tag|
        tags << tag.first
      end
      channel.set_post_tags(self, tags)
    end
  end

end
