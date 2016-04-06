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
    def self.mentioned_logins_in(text)
      text.gsub Channel::MentionPattern do |match|
        login = $1
        yield match, login, false
      end
    end
  end

  class AutoEmbedFilter < Pipeline::Filter
    EMBEDS = {
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
          p [content, id]
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
        pattern: %r{http://(i.)?imgur.com/([a-zA-Z0-9]+)\.gifv},
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
    Pipeline::EmojiFilter,
    AutoEmbedFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT
  SIMPLE_PIPELINE = Pipeline.new [
    SimpleFormatFilter,
    # Pipeline::ImageMaxWidthFilter,
    PreserveFormatting,
    BetterMentionFilter,
    Pipeline::EmojiFilter,
    AutoEmbedFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT
  TITLE_PIPELINE = Pipeline.new [
    Pipeline::MarkdownFilter,
    Pipeline::EmojiFilter
  ], PIPELINE_CONTEXT
  NOTIFICATION_PIPELINE = Pipeline.new [
    Pipeline::MarkdownFilter,
    BetterMentionFilter,
    Pipeline::EmojiFilter,
    AutoEmbedFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT

  class << self
    def markdown(text, post_id=nil)
      result = MARKDOWN_PIPELINE.call(text, post_id: post_id)
      result[:output].to_s
    end

    def simple(text, post_id=nil)
      result = SIMPLE_PIPELINE.call(text, post_id: post_id)
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
