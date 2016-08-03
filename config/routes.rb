Rails.application.routes.draw do
  devise_for :users
  namespace :api, defaults: { format: :json } do
    scope module: :v1 do
      resources :users,   :only =>  [:show, :create, :update, :destroy]
      resources :sessions,:only =>  [:create, :destroy]
      resources :articles
      post '/like_dislike_user' => 'users#like_dislike_user'
      get  '/liked_users'       => 'users#liked_users'
      get  '/disliked_users'    => 'users#disliked_users'
      get  '/neutral_users'     => 'users#neutral_users'
      get  '/my_likers'         => 'users#my_likers'
      get  '/my_dislikers'      => 'users#my_dislikers'
      get  '/my_articles'       => 'articles#my_articles'
      post '/vote'              => 'articles#vote'
      post '/comment'           => 'articles#comment'
      get '/my_fav_articles'   => 'articles#my_fav_articles'
    end
  end
end