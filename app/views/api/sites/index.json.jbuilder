json.sites @sites do |s|
  json.partial! 'shared/site', site: s
end
