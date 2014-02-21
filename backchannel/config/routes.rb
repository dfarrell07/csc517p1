Backchannel::Application.routes.draw do
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up", to: "users#new", as: "sign_up"
  get "/posts/up_vote/:id", to: "posts#up_vote", as: "up_vote_post"
  get "/posts/:post_id/new_comment/", to: "posts#new_comment", as: "new_comment"
  post "/posts/:post_id/create_comment/", to: "posts#create_comment", as: "create_comment"
  root to: "users#new"
  resources :posts
  resources :users
  resources :sessions
  resources :categories
end
