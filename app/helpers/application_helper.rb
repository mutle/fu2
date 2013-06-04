module ApplicationHelper

  def fu3_templates
    File.read(File.expand_path("./app/views/shared/fu3_templates.html", Rails.root)).html_safe
  end

end
