json.post do
  json.body @post.body
  json.topic "/#{@post.topic.title}"
  json.created_at @post.created_at
end
