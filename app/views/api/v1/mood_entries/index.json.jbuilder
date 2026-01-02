json.records @mood_entries do |entry|
  json.partial! "mood_entry", mood_entry: entry
end

json.count @mood_entries.count
json.url "No URL available for this action"
