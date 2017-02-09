json.array! @categories do |c|
  json.id c.id
  json.name c.name
  json.display_name c.display_name
  # yes, this is ineffiecnt
  json.aliases c.aliases
end
