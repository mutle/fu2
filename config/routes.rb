require "resque_web"

Fu2::Application.routes.draw do
  mount ResqueWeb::Engine => "/resque", as: "resque"

  namespace :api do
    resources :channels do
      resources :posts
    end
    resources :posts do
      member do
        post :fave
      end
    end

    resources :notifications do
      member do
        post :read
      end
      collection do
        get :unread
        get :counters
      end
    end
    resources :images
  end

  resources :users do
    member do
      put :block
      get :activate
      get :password
    end
  end

  resources :invites do
    member do
      put :approve
    end
  end

  resource :session, :controller => :session do
    collection do
      post :authenticate
    end
  end

  resource :search, :controller => :search

  resources :channels do
    collection do
      get :search
      get :channel_names
      get :activity
      get :live
      get :all
    end
    member do
      post :visit
      get :merge
      post :do_merge
    end
  end

  resources :notifications

  resources :images
  resources :stylesheets

  get '/stats/websockets' => "stats#websockets"
  get '/tests' => "tests#index"

  get '/' => 'channels#index', :as => :root
end
