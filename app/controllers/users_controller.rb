class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    @user.username.downcase!

    if @user.save
      @post = Post.new()
      @post.user = @user
      @post.body = "##{@user.username} blog just started."
      @post.topic = Topic.from_post(@post)
      @post.save
      render json: {
        user: @user.as_json( except: [:password_digest, :token] ),
        token: @user.token
      }, status: :created
    else
      render :json => @user.errors, status: :bad_request
    end
  end

  def get_token
    @user = User.find_by(username: user_params[:username].downcase)
    if @user && @user.authenticate(user_params[:password])
      @user.password = user_params[:password]
      @user.password_confirmation = user_params[:password]
      @user.regenerate_token
      render json: {
        user: @user.as_json( except: [:password_digest, :token] ),
        token: @user.token
      }
    else
      render :json => {}, status: :unauthorized
    end
  end

private
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
