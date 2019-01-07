class Topic < ApplicationRecord
  belongs_to :user
  has_many :posts

  def self.from_post(post)
    @validator = OnehashValidator.new()
    @validator.validate(post)
    if post.errors.blank?
      start = post.body.index('#')
      stop = post.body.index(' ', start)
      if stop
        title = post.body[start+1..stop-1].downcase
      else
        title = post.body[start+1..-1].downcase
      end
      @topic = Topic.find_by(title: title)
      unless @topic
        @topic = Topic.new()
        @topic.title = title
        @topic.user = post.user
      end
      return @topic
    else
      return nil
    end
  end
end
