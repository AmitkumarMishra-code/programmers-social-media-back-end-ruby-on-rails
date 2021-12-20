Rails.application.routes.draw do
  post '/auth/login', to: 'authentication#login'
  get '/logout', to: 'authentication#logout'
  post 'auth/token', to: 'authentication#refresh'
  resources :followings
  get '/followers/:id', to: 'followings#followers'
  post '/follow/:username', to: 'followings#create'
  post '/unfollow/:username', to: 'followings#destroy'
  resources :users, only: [:create, :index]
  get '/profile', to: 'users#selfprofile'
  get '/profile/:id', to: 'users#friendprofile'
  resources :likes, only: [:create, :destroy]
  post '/like/:id', to: 'likes#create'
  post '/unlike/:id', to: 'likes#destroy'
  resources :posts, only: [:index, :create, :destroy]
  post '/post', to: 'posts#create'
  get '/feed', to: 'posts#feed'
  resources :tokens
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
