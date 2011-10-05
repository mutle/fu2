# ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
#   css_class_name = "error"
#   if html_tag =~ /<(input)[^>]+type=["'](checkbox|radio)/
#     "<div class='error_container'>#{html_tag}</div>"
#   elsif html_tag =~ /<label/
#     html_tag
#   else
#     if html_tag.downcase.include?("class=")      
#       position = html_tag.chars.downcase.index('class=') + 'class='.chars.length+1
#       string = css_class_name+' '
#     else
#       position = html_tag.at(html_tag.chars.index(">")-1) == "/" ? html_tag.chars.index('>')-1 : html_tag.chars.index('>')
#       string = " class=\"#{css_class_name}\" "
#     end
#     html_tag.insert(position, string)
#   end
# end
