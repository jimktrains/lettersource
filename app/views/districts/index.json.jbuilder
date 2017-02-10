json.array! @districts do |d|
  json.id d['id']
  json.type d['type']
  json.name d['name']
  # For selectize to show it in the dropdown
  json.one_zip @zip
end

