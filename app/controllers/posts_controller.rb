class PostsController < ApplicationController
  before_action :require_token
  def post
  end

private
  def post_params
    params.require(:post).permit(:body)
  end
end
