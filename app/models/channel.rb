class Channel < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  MentionPattern = /
    (?:^|\W|\n)                   # beginning of string or non-word char
    @((?>[^\s\.,\/-][^\s\.,\/]*))  # @username
    (?!\/)                     # without a trailing slash
    (?=
      \.+[ \t\W]|              # dots followed by space or non-word character
      \.+$|                    # dots at end of line
      [^0-9a-zA-Z_.]|          # non-word character except dot
      $                        # end of line
    )
  /ix

  belongs_to :user
  has_many :posts, :order => "created_at"
  has_many :channel_users
  has_many :channel_visits
  
  validates_presence_of :title, :user_id
  validates_uniqueness_of :title, :on => :create
  
  before_create :generate_permalink
  after_create :add_first_post

  attr_accessor :current_user, :markdown
  
  index_name "channels-#{Rails.env}"

  mapping do
    indexes :_id, :index => :not_analyzed
    indexes :title, :analyzer => 'snowball', :boost => 100
    indexes :created_at, :type => 'date', :index => :not_analyzed
  end
  
  # define_index do
  #   indexes title
  #   set_property :field_weights => {:title => 100}
  # end

  def to_indexed_json
    {
      :_id => _id,
      :title => title,
      :created_at => created_at
    }.to_json
  end
  
  
  def self.recent_channels(_user, page, per_page = 50)
    self.paginate :conditions => ["(default_read = ? AND default_write = ?) OR user_id = ?", true, true, _user.id], :order => "last_post DESC", :page => page, :per_page => per_page
  end
  
  def self.all_channels(_user, page)
    self.paginate :conditions => ["(default_read = ? AND default_write = ?) OR user_id = ?", true, true, _user.id], :order => "LOWER(title)", :page => page, :per_page => 100
  end

  def self.search_channels(title, page)
    search :per_page => 25, :page => page, :load => true do
      query do
        boolean do
          title.split(' ').each do |t|
            must { string "*#{t}*" }
          end
        end
      end
    end
  end

  def self.search_channels_and_posts(searchquery, page)
    Tire.search ["channels-#{Rails.env}", "posts-#{Rails.env}"], :load => true do
      per_page = 25
      size per_page
      from page.to_i <= 1 ? 0 : (per_page.to_i * (page.to_i-1))
      searchquery.split(' ').each do |q|
        query { string q }
      end
    end.results
  end
  
  def body=(body)
    @body ||= body
  end
  
  def body
    ""
  end
  
  def add_first_post
    posts.create(:body => @body || "... has nothing to say", :user_id => user_id, :markdown => @markdown) if @body
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

  def as_json(*args)
    {:created_at => created_at, :id => id, :last_post => last_post, :permalink => permalink, :title => title, :updated_at => updated_at, :user_id => user_id, :read => @current_user ? visited?(@current_user) : false}
  end

  def last_read_id(current_user)
    $redis.zscore("last-post:#{current_user.id}", id) || 0
  end

  def num_unread(current_user)
    posts.where("id > :last_id", :last_id => last_read_id(current_user)).count
  end
  
  def has_posts?(current_user)
    i = last_read_id(current_user)
    i == 0 || i < posts.last.id
  end
  
  def visit(current_user)
    $redis.zadd "last-post:#{current_user.id}", posts.last.id, id
    $redis.zadd "mentions:#{current_user.id}", 0, id
  end
  
  def delete_visits
    channel_visits.delete_all
  end

  def num_mentions(current_user)
    ($redis.zscore("mentions:#{current_user.id}", id) || 0).to_i
  end

  def add_mention(user)
    $redis.zincrby "mentions:#{user.id}", 1, id 
  end
  
end
