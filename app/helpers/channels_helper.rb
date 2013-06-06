module ChannelsHelper
  include HTML


  class SimpleFormatFilter < Pipeline::Filter
    include ActionView::Helpers::TextHelper
    def call
      if html.size < 64000
        simple_format(html, {}, :sanitize => false)
      else
        html
      end
    end
  end
  class PreserveFormatting < Pipeline::Filter
    def call
      html.gsub /<([^\/a-zA-Z])/, '&lt;\1'
    end
  end
  class BetterMentionFilter < Pipeline::MentionFilter
    BetterMentionPattern = /
      (?:^|\W)                   # beginning of string or non-word char
      @((?>[^\s\.,\/-][^\s\.,\/]*))  # @username
      (?!\/)                     # without a trailing slash
      (?=
        \.+[ \t\W]|              # dots followed by space or non-word character
        \.+$|                    # dots at end of line
        [^0-9a-zA-Z_.]|          # non-word character except dot
        $                        # end of line
      )
    /ix

    def self.mentioned_logins_in(text)
      text.gsub BetterMentionPattern do |match|
        login = $1
        yield match, login, false
      end
    end
  end

  PIPELINE_CONTEXT = {
    :asset_root => "/images",
    :base_url => "/users"
  }

  MARKDOWN_PIPELINE = Pipeline.new [
    Pipeline::MarkdownFilter,
    # Pipeline::ImageMaxWidthFilter,
    BetterMentionFilter,
    Pipeline::EmojiFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT
  SIMPLE_PIPELINE = Pipeline.new [
    SimpleFormatFilter,
    # Pipeline::ImageMaxWidthFilter,
    PreserveFormatting,
    BetterMentionFilter,
    Pipeline::EmojiFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT
  TITLE_PIPELINE = Pipeline.new [
    Pipeline::PlainTextInputFilter,
    Pipeline::EmojiFilter
  ], PIPELINE_CONTEXT

  def format_body(post)
    pipeline = post.markdown? ? MARKDOWN_PIPELINE : SIMPLE_PIPELINE
    result = pipeline.call(post.body)
    return result[:output].to_s.html_safe
  end

  def user_link(user)
    return "" unless user
    link_to h(user.login), user_path(user), :style => user.display_color
  end

  def user_name(user)
    user_link(user)
  end

  def format_title(channel)
    TITLE_PIPELINE.call(channel.title)[:output].to_s.html_safe
  end

  def avatar_url(user, size=42)
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

end
