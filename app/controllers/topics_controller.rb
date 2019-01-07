class TopicsController < ApplicationController
  before_action :require_token
  def show
    unless @topic = Topic.find_by(title: params[:topic_title].downcase)
      render json: {}, status: :not_found
    end
  end

  def index
    @topics = Topic.all.sort_by {|topic| topic.posts.length }.reverse
  end
end
