json.records @affirmation_entries do |entry|
  json.partial! "affirmation_entry", affirmation_entry: entry
end

json.count @affirmation_entries.count
json.url "No URL available for this action"
