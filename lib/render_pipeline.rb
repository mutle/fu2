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
  NOTIFICATION_PIPELINE = Pipeline.new [
    Pipeline::MarkdownFilter,
    BetterMentionFilter,
    Pipeline::EmojiFilter,
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
