json.array! @critters do |c|
  json.state c.state
  json.district c.district
  json.name c.name
  json.desdcription c.parentetical
  json.address c.recipient_array
end
