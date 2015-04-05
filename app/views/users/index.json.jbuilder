json.users @users do |u|
  json.(u, :id, :created_at, :updated_at, :login, :display_name, :display_name_html, :display_color)
  json.avatar_ur u.avatar_image_url
end
