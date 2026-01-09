json.records @books do |book|
  json.partial! "book", book: book
end

json.count @books.count
json.url "No URL available for this action"
