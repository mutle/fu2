class Channel < ActiveRecord::Base
  include SiteScope

  scope :with_letter, proc { |site, c| site_scope(site).where("LOWER(title) LIKE '#{c}%'").paginate(:per_page => 1_000_000, :page => 1).order("LOWER(title)") }
  scope :with_ids, proc { |ids| where(id: ids) }

  MentionPattern = /
    (?:^|\W|\n)                   # beginning of string or non-word char
    @((?>[^\s\.,\/-][^\s\.:,\/]*))  # @username
    (?!\/)                     # without a trailing slash
    (?=
      \.+[ \t\W]|              # dots followed by space or non-word character
      \.+$|                    # dots at end of line
      [^0-9a-zA-Z_.]|          # non-word character except dot
      $                        # end of line
    )
  /ix

  belongs_to :user
  has_many :posts, lambda { order("created_at DESC") }
  has_many :channel_users
  has_many :events

  validates_presence_of :title, :user_id
  validates_uniqueness_of :title, :on => :create, :scope => [:site_id]

  before_create :generate_permalink
  after_create :add_first_post

  after_create :notify_create
  after_update :notify_update

  after_create :update_index
  after_update :update_index
  before_destroy :remove_index

  attr_accessor :current_user, :markdown, :read, :query

  class << self
    def indexed_type
      "channel"
    end

    def index_definition
      {
        settings: {},
        mappings: {
          indexed_type => {
            properties: {
              title: { type: 'string', analyzer: 'simple' },
              created: { type: 'date', index: 'not_analyzed' },
              text: { type: 'string', analyzer: 'standard' },
              site_id: { type: 'integer', index: 'not_analyzed' }
            }
          }
        }
      }
    end
  end

  def to_indexed_json
    {
      :_id => id,
      :_type => self.class.indexed_type,
      :title => title,
      :created => created_at,
      :text => text,
      :site_id => site_id
    }
  end

  def self.filter_ids(site, query, current_user)
    return nil if !query
    ids = nil
    if !query[:text].blank?
      q = query[:text].split(" ").map { |t| t.length > 1 ? "title:#{t}" : nil }.compact.join(" ")
      # TODO site scope for search
      res = Search.query(q, type: "channels", per_page: 500, sort: "score").results
      ids = res[:objects].compact.map(&:id) if res[:result_count] <= 500
    end
    if query[:unread]
      temp_ids = ids || site_scope(site).reorder("last_post_date DESC").limit(500).to_a.map(&:id)
      ids = []
      temp_ids.each do |r|
        last_id = ($redis.zscore("last-post:#{current_user.id}", r) || 0).to_i
        if last_id == 0
          ids << r
        end
      end
    end
    ids
  end

  def self.recent_channels(site, user, page, per_page = 50, last_update=nil, ids=nil)
    results = if ids
      site_scope(site).where(id: ids)
    else
      Channel.site_scope(site)
    end

    if last_update
      results = results.where("updated_at > ? OR last_post_date > ?", last_update, last_update)
    end
    results = results.where("(default_read = ? AND default_write = ?) OR user_id = ? AND last_post_date != NULL", true, true, user.id)
    results.reorder("last_post_date DESC").paginate(page: page, per_page: per_page)
  end

  def self.all_channels(site, _user, page)
    where("((default_read = ? AND default_write = ?) OR user_id = ?) AND site_id = ?", true, true, _user.id, site.id).order("LOWER(title)").paginate(:page => page, :per_page => 100).load
  end

  def body=(body)
    @body ||= body
  end

  def body
    @body || ""
  end

  def add_first_post
    posts.create(:body => @body || "... has nothing to say", :user_id => user_id, :markdown => @markdown, :site_id => site_id)
  end

  def generate_permalink
    self.permalink = title.gsub(/ /, '_').gsub(/[^a-zA-Z0-9_\-]/, '')
  end

  def can_read?(_user)
    return false unless _user
    return true if _user.id == user_id
    default_read
  end

  def can_write?(_user)
    return false unless _user
    return true if _user.id == user_id
    default_write
  end

  def last_post_user_id
    last_post.try(:user_id) || 0
  end

  # def as_json(*args)
  #   {:created_at => created_at, :id => id, :last_post => last_post, :last_post_user_id => (Post.first_channel_post(self).first.user_id rescue 0), :permalink => permalink, :title => title, :updated_at => updated_at, :user_id => user_id, :read => @current_user ? has_posts?(@current_user) : false}
  # end

  def last_read_id(current_user)
    ($redis.zscore("last-post:#{current_user.id}", id) || 0).to_i
  end

  def last_post
    @last_post ||= posts.reorder("id DESC").first
  end

  def last_post=(post)
    @last_post = post
  end

  def last_post_id
    last_post.try(:id)
  end

  def num_unread(current_user)
    posts.where("id > :last_id", :last_id => last_read_id(current_user)).count
  end

  def has_posts?(current_user, post=nil)
    i = last_read_id(current_user)
    (i == 0 || (post || last_post).nil? || i < (post || last_post).id) == true
  end

  def visit(current_user, post_id=nil)
    if !post_id
      num = $redis.zscore "mentions:#{current_user.id}", id
      $redis.zadd "mentions:#{current_user.id}", 0, id
      Live.notification_counters(current_user) if num && num.to_i > 0
    end
    post_id ||= (last_post_id || 0)
    i = last_read_id(current_user).to_i
    if user && i != post_id
      self.read = true
      Live.channel_update(self, current_user)
    elsif user && post_id == nil
      self.read = true
    end
    $redis.zadd "last-post:#{current_user.id}", post_id, id
    Notification.for_user(current_user).mentions.in_channel(self).unread.update_all(:read => true)
    i
  end

  def num_mentions(current_user)
    ($redis.zscore("mentions:#{current_user.id}", id) || 0).to_i
  end

  def add_mention(user)
    $redis.zincrby "mentions:#{user.id}", 1, id
  end

  def updated_by_user
    updated_by && User.find(updated_by)
  end

  def show_posts(current_user, last_read, per_page=12)
    p = posts.where("id >= :last_read", last_read: last_read).includes(:user, :faves).load.reverse
    if p.size < per_page
      p = posts.includes(:user, :faves).limit(per_page).load.reverse
    end
    if p.first
      e = events.includes(:user).from_post(p.first)
      result = p + e
    else
      result = p
    end
    result.sort_by(&:created_at)
  end

  def merge(other, current_user)
    Post.where(channel_id: other.id).update_all(channel_id: id)
    events.create(event: "merge", data: {merged_title: other.title, title: title}, user_id: current_user.id)
    ChannelRedirect.create(original_channel_id: other.id, target_channel_id: id)
    other.destroy
  end

  def rename(name, current_user)
    old_title = self.title
    return if old_title == name
    self.title = name
    events.create(event: "rename", data: {old_title: old_title, title: title}, user_id: current_user.id)
  end

  def change_text(text, current_user)
    old_text = self.text
    old_text_html = RenderPipeline.markdown(old_text)
    return if old_text == text || (old_text.blank? && text.blank?)
    self.text = text
    text_html = RenderPipeline.markdown(text)
    events.create(event: "text", data: {old_text: old_text, old_text_html: old_text_html, text: text, text_html: text_html}, user_id: current_user.id)
  end

  def last_text_change
    change = events.where(event: "text").last
    return {user_id: change.user.id, updated_at: change.created_at} if change
    nil
  end

  def update_index
    Search.update("channels", id)
  end

  def remove_index
    Search.remove("channels", id)
  end

  def notify_create
    Live.channel_create self
  end

  def notify_update
    Live.channel_update self
  end

end
