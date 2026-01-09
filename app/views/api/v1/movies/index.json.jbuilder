json.records @movies do |movie|
  json.partial! "movie", movie: movie
end

json.count @movies.count
json.url "No URL available for this action"
