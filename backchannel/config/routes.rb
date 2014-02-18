Backchannel::Application.routes.draw do
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up", to: "users#new", as: "sign_up"
  get "/posts/up_vote/:id", to: "posts#up_vote", as: "up_vote_post"
  root to: "users#new"
  resources :posts
  resources :users
  resources :sessions
  resources :categories
end
