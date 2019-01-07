json.topics @topics do |topic|
  json.topic "/#{topic.title}"
  json.user topic.user.username
  json.created_at topic.created_at
  json.n_posts topic.posts.length
  json.latest_post do
    json.body topic.posts.last.body
    json.created_at topic.posts.last.created_at
    json.author topic.posts.last.user.username
    json.topic topic.posts.last.topic.title
  end
end
