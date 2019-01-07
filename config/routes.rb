Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'topics#index'
  post '/' => 'posts#post'

  post '/signup' => 'users#create'
  post '/signin' => 'users#get_token'

  get '/:topic_title' => 'topics#show'
end
