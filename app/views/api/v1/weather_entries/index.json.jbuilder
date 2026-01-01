json.records @weather_entries do |entry|
  json.partial! "weather_entry", weather_entry: entry
end

json.count @weather_entries.count
json.url "No URL available for this action"
