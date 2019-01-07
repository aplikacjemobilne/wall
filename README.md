https://documenter.getpostman.com/view/6299541/RznEJyBz

### Generowanie

`rails new sciana --api`

### Gemfile
```
gem 'jbuilder', '~> 2.5'
gem 'bcrypt', '~> 3.1.7'
```

`bundle install`

### Schema

`rails g model User username:string password_digest:string token:string`

`rails g model Topic title:string user:references`

`rails g model Post body:string user:references topic:references`

### Model

`User.rb`
```ruby
has_many :posts
has_many :topics

has_secure_password
has_secure_token

validates_presence_of     :password
validates_confirmation_of :password
validates_presence_of :password_confirmation, if: :password_digest_changed?

validates :username, presence: true, uniqueness: true
```

`Topic.rb`
```ruby
belongs_to :user
has_many :posts
```

`Post.rb`
```ruby
belongs_to :user
belongs_to :topic

validates_presence_of :user
validates_presence_of :topic
```

### Routing

`routes.rb`
```ruby
get '/' => 'topics#index'
post '/' => 'posts#post'

post '/signup' => 'users#create'
post '/signin' => 'users#get_token'

get '/:topic_title' => 'topics#show'
```

### Kontrolery

`rails generate controller Users create get_token`
```ruby
private
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
```

`rails generate controller Posts post`
```ruby
private
  def post_params
    params.require(:post).permit(:body)
  end
```

`rails generate controller Topics show index`

### Rejestracja

`users_controller.rb`
```ruby
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
```

### Autentykacja

`application_controller.rb`
```ruby
include ActionController::HttpAuthentication::Token::ControllerMethods

class ApplicationController < ActionController::API
    def authenticate_token
      authenticate_with_http_token do |token, options|
        @user ||= User.find_by(token: token)
      end
    end

    def render_unauthorized(message)
      errors = { errors: [ { detail: message } ] }
      render json: errors, status: :unauthorized
    end

    def require_token
      authenticate_token || render_unauthorized("Access denied")
    end
end
```

`pozostałe kontrolery`
```
before_action :require_token
```


### Walidator i automatyczna kreacja tematów

`models/concerns/onehas_validator.rb`
```ruby
class OnehashValidator < ActiveModel::Validator
  def validate(record)
    counter = record.body.scan(/# /).length
    if counter > 0
      record.errors.add(:body, "Empty tag found")
    end

    counter = record.body.count("#")
    if counter != 1
      record.errors.add(:body, "#{counter} tags, where should be exactly 1")
    end
  end
end
```

`Post.rb`
```ruby
validates_with OnehashValidator
```

`Topic.rb`
```ruby
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
```

### Tworzenie posta i wyświetlanie tematu

`posts_controller.rb`
```ruby
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
```

`topics_controller.rb`
```ruby
def show
  unless @topic = Topic.find_by(title: params[:topic_title].downcase)
    render json: {}, status: :not_found
  end
end

def index
  @topics = Topic.all.sort_by {|topic| topic.posts.length }.reverse
end
```

### Widoki

`posts/post.json.jbuilder`
```ruby
json.post do
  json.body @post.body
  json.topic "/#{@post.topic.title}"
  json.created_at @post.created_at
end
```

`topics/index.json.jbuilder`
```ruby
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
```

`topics/show.json.jbuilder`
```ruby
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
```
