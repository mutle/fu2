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
        pattern: %r{https?://(m\.)?twitter\.com/[^/]+/status/(\d+)},
        callback: proc do |content, id|
          tweet = $redis.get "Tweets:#{id}"
          if !tweet
            Resque.enqueue(FetchTweetJob, id)
            content
          else
            content.gsub(EMBEDS[:twitter][:pattern], tweet)
          end
        end
      },
      youtube: {
        pattern: %r{https?://(www\.youtube\.com/watch\?v=|youtu\.be/)([A-Za-z\-_0-9]+)},
        callback: proc do |content, id|
          content.gsub EMBEDS[:youtube][:pattern], %{<iframe width="560" height="315" src="//www.youtube.com/embed/#{id}" frameborder="0" allowfullscreen></iframe>}
        end
      }
    }

    def call
      doc.search('text()').each do |node|
        next unless node.respond_to?(:to_html)
        content = node.to_html
        EMBEDS.each do |k,embed|
          if content =~ embed[:pattern]
            html = embed[:callback].call(content, $2)
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
    Pipeline::PlainTextInputFilter,
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
    def markdown(text)
      result = MARKDOWN_PIPELINE.call(text)
      result[:output].to_s
    end

    def simple(text)
      result = SIMPLE_PIPELINE.call(text)
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
