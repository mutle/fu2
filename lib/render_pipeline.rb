module RenderPipeline
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
    def self.mentioned_logins_in(text, username_pattern=Channel::UsernamePattern)
      text.gsub Channel::MentionPatterns[Channel::UsernamePattern] do |match|
        login = $1
        yield match, login, false
      end
    end

    def link_to_mention_info(text, info_url=nil)
      Rails.logger.info context.inspect
      self_mention = " own" if context[:user_login] && text.downcase == context[:user_login].downcase
      return "@#{text}" if info_url.nil?
      "<a href='#{info_url}' class='user-mention#{self_mention}'>" +
      "@#{text}" +
      "</a>"
    end
  end

  class CustomEmojiFilter < Pipeline::EmojiFilter
    def emoji_image_filter(text)
      regex = emoji_pattern
      text.gsub(regex) do |match|
        emoji_image_tag($1)
      end
    end

    def self.emoji_names
      super + CustomEmoji.custom_emojis.map { |e| e[:aliases] }.flatten.sort
    end

    def self.emoji_pattern
      last_update = CustomEmoji.last_update
      if !@last_update || @last_update < last_update || !@emoji_pattern
        @emoji_pattern = /:(#{emoji_names.map { |name| Regexp.escape(name) }.join('|')}):/
        @last_update = last_update
      end
      @emoji_pattern
    end

    def emoji_image_tag(name)
      "<img class='emoji' title=':#{name}:' alt=':#{name}:' src='#{emoji_url(name)}' height='20' width='20' align='absmiddle' />"
    end

    def emoji_url(name)
      e = CustomEmoji.custom_emojis.find { |e| e[:aliases].include?(name) }
      return e[:image] if e
      super(name)
    end
  end

  class AutoEmbedFilter < Pipeline::Filter
    EMBEDS = {
      redcursor: {
        pattern: %r{https?://(#{(ENV["REDCURSOR_HOSTNAMES"] || "").gsub(/\./, "\\.").split(",").join("|")})/channels/([0-9]+(#[^ $]+)?)},
        callback: proc do |content,id|
          content.gsub(EMBEDS[:redcursor][:pattern], %{<a href="/channels/#{id}">#{Channel.find(id.to_i).title rescue "/channels/#{id}"}</a>})
        end
      },
      redcursor_upload: {
        pattern: %r{https?://files\.redcursor\.net/uploads/},
        callback: proc do |content,id|
          content.gsub(EMBEDS[:redcursor_upload][:pattern], %{https://redcursor.net/uploads/})
        end
      },
      redcursor_tag: {
        pattern: Channel::TagPattern,
        callback: proc do |content, tag, id, m|
          content.gsub(EMBEDS[:redcursor_tag][:pattern], %{#{m[1]}<a class="hash-tag" href="/channels/tags/#{m[3]}">##{m[3]}</a>})
        end
      },
      twitter: {
        pattern: %r{https?://(m\.|mobile\.)?twitter\.com/[^/]+/statuse?s?/(\d+)},
        callback: proc do |content, id, post_id|
          tweet = $redis.get "Tweets:#{id}"
          if !tweet
            Resque.enqueue(FetchTweetJob, id, post_id, :tweet)
            content
          else
            tweet.gsub!(/<script.*>.*<\/script>/, "")
            content.gsub(EMBEDS[:twitter][:pattern], tweet)
          end
        end
      },
      youtube: {
        pattern: %r{https?://(www\.youtube\.com/watch\?v=|m\.youtube\.com/watch\?.*v=|youtu\.be/)([A-Za-z\-_0-9]+)[^ ]*},
        callback: proc do |content, id|
          content.gsub EMBEDS[:youtube][:pattern], %{<iframe width="560" height="315" src="//www.youtube.com/embed/#{id}" frameborder="0" allowfullscreen></iframe>}
        end
      },
      instagram: {
        pattern: %r{https?://(instagram\.com|instagr\.am)/p/([A-Za-z0-9]+)/?},
        callback: proc do |content, id, post_id|
          image = $redis.get "Instagram:#{id}"
          if !image
            Resque.enqueue(FetchTweetJob, id, post_id, :instagram)
            content
          else
            content.gsub(EMBEDS[:instagram][:pattern], image)
          end
        end
      },
      facebook: {
        pattern: %r{https?://www.facebook.com/[^/]+/((videos|posts)/[0-9]+)/?},
        callback: proc do |content, id, post_id, match|
          "<div class=\"fb-#{match[2].to_s.gsub(/s$/, '')}\" data-href=\"#{match[0]}\" data-width=\"500\" data-allowfullscreen=\"true\"></div>"
        end
      },
      imgur: {
        pattern: %r{https?://(i.)?imgur.com/([a-zA-Z0-9]+)\.gifv},
        callback: proc do |content, id|
          "<video poster=\"//i.imgur.com/#{id}.jpg\" preload=\"auto\" autoplay=\"autoplay\" muted=\"muted\" loop=\"loop\" webkit-playsinline=\"\" style=\"width: 480px; height: 270px;\"><source src=\"//i.imgur.com/#{id}.webm\" type=\"video/webm\"><source src=\"//i.imgur.com/#{id}.mp4\" type=\"video/mp4\"></video>"
        end
      }
    }

    def call
      doc.search('.//text()').each do |node|
        next unless node.respond_to?(:to_html)
        content = node.to_html
        EMBEDS.each do |k,embed|
          if m = content.match(embed[:pattern])
            html = embed[:callback].call(content, m[2], context[:post_id], m)
            next if html == content
            node.replace(html)
          end
        end
      end
      doc
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
    CustomEmojiFilter,
    AutoEmbedFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT
  SIMPLE_PIPELINE = Pipeline.new [
    SimpleFormatFilter,
    # Pipeline::ImageMaxWidthFilter,
    PreserveFormatting,
    BetterMentionFilter,
    CustomEmojiFilter,
    AutoEmbedFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT
  TITLE_PIPELINE = Pipeline.new [
    Pipeline::MarkdownFilter,
    CustomEmojiFilter
  ], PIPELINE_CONTEXT
  NOTIFICATION_PIPELINE = Pipeline.new [
    Pipeline::MarkdownFilter,
    BetterMentionFilter,
    CustomEmojiFilter,
    AutoEmbedFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT

  class << self
    def markdown(text, post_id=nil, user_login=nil)
      result = MARKDOWN_PIPELINE.call(text, {post_id: post_id, user_login: user_login})
      result[:output].to_s
    end

    def simple(text, post_id=nil, user_login=nil)
      result = SIMPLE_PIPELINE.call(text, {post_id: post_id, user_login: user_login})
      result[:output].to_s
    end

    def title(text)
      result = TITLE_PIPELINE.call(text)
      result[:output].to_s
    end

    def notification(text)
      result = NOTIFICATION_PIPELINE.call(text)
      result[:output].to_s
    end
  end
end
