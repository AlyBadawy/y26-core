json.records @water_intake_entries do |entry|
  json.partial! "water_intake_entry", water_intake_entry: entry
end

json.count @water_intake_entries.count
json.url "No URL available for this action"
