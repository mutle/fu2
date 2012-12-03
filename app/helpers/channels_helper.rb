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

  PIPELINE_CONTEXT = {
    :asset_root => "/images",
    :base_url => "/users"
  }

  MARKDOWN_PIPELINE = Pipeline.new [
    Pipeline::MarkdownFilter,
    Pipeline::ImageMaxWidthFilter,
    Pipeline::MentionFilter,
    Pipeline::EmojiFilter,
    Pipeline::AutolinkFilter
  ], PIPELINE_CONTEXT
  SIMPLE_PIPELINE = Pipeline.new [
    SimpleFormatFilter,
    Pipeline::ImageMaxWidthFilter,
    Pipeline::MentionFilter,
    Pipeline::EmojiFilter,
    Pipeline::AutolinkFilter
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
    "&lt;".html_safe + user_link(user) + "&gt;".html_safe
  end
  
end
