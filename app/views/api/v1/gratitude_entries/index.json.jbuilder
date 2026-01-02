json.records @gratitude_entries do |entry|
  json.partial! "gratitude_entry", gratitude_entry: entry
end

json.count @gratitude_entries.count
json.url
