class PostsController < ApplicationController
  before_action :require_token
  def post
    @post = Post.new(post_params)
    @post.user = @user
    @post.topic = Topic.from_post(@post)

    if @post.save
      render status: :created
    else
      render :json => @post.errors, status: :bad_request
    end
  end

private
  def post_params
    params.require(:post).permit(:body)
  end
end
