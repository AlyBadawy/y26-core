json.records @journal_entries do |entry|
  json.partial! "journal_entry", journal_entry: entry
end

json.count @journal_entries.count
json.url "No URL available for this action"
