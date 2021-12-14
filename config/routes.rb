Rails.application.routes.draw do
  post '/auth/login', to: 'authentication#login'
  post 'auth/token', to: 'authentication#refresh'
  resources :followings
  resources :users
  resources :likes
  resources :posts
  resources :tokens
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
