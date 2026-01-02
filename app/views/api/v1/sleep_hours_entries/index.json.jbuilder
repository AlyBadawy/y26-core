json.records @sleep_hours_entries do |entry|
  json.partial! "sleep_hours_entry", sleep_hours_entry: entry
end

json.count @sleep_hours_entries.count
json.url "No URL available for this action"
