json.topic do
  json.topic "/#{@topic.title}"
  json.user @topic.user.username
  json.created_at @topic.created_at
  json.n_posts @topic.posts.length
  json.posts @topic.posts.reverse do |post|
    json.body post.body
    json.created_at post.created_at
    json.author post.user.username
  end
end
