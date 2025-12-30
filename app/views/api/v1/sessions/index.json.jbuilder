json.records @sessions do |session|
  json.partial! "session", session: session
end

json.count @sessions.count
json.url "No URL available for this action"
