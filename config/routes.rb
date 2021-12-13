Rails.application.routes.draw do
  resources :tokens
  post '/auth/login', to: 'authentication#login'
  post 'auth/token', to: 'authentication#refresh'
  resources :followings
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
