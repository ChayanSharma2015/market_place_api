Rails.application.routes.draw do
  devise_for :users
  namespace :api, defaults: { format: :json } do
    scope module: :v1 do
      resources :users,      :only =>  [:show, :create, :update, :destroy]
      resources :sessions,   :only =>  [:create, :destroy]
      post '/liked_disliked_users' => 'users#liked_disliked_users'
      get  '/show_liked_users'     => 'users#show_liked_users'
      get  '/show_disliked_users'  => 'users#show_disliked_users'
      get  '/neutral_users'        => 'users#neutral_users'
    end
  end
end
