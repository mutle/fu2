class Post < ActiveRecord::Base
  
  belongs_to :channel
  belongs_to :user
  has_many :faves

  scope :first_channel_post, proc { |c| includes(:user).where(:channel_id => c.id).order("created_at DESC").limit(1) }
  
  after_create :delete_channel_visits
  after_create :update_channel_last_post

  # before_create :set_markdown
  # before_update :set_markdown
  
  define_index do
    indexes body
    has channel(:default_read)
    where sanitize_sql(['default_read', true])
  end
  
  def delete_channel_visits
    channel.delete_visits
  end
  
  def update_channel_last_post
    channel.update_attribute(:last_post, created_at)
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
