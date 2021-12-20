Rails.application.routes.draw do
  post '/auth/login', to: 'authentication#login'
  post 'auth/token', to: 'authentication#refresh'
  resources :followings
  get '/followers/:id', to: 'followings#followers'
  resources :users, only: [:create]
  get '/profile', to: 'users#selfprofile'
  get '/profile/:id', to: 'users#friendprofile'
  resources :likes, only: [:create, :destroy]
  resources :posts, only: [:index, :create, :destroy]
  get '/feed', to: 'posts#feed'
  resources :tokens
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
