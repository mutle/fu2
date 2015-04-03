require "resque_web"

Fu2::Application.routes.draw do
  mount ResqueWeb::Engine => "/resque", as: "resque"

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
    end
    resources :posts do
      member do
        post :unread
      end
    end
  end

  resources :posts do
    member do
      post :fave
    end
    collection do
      get :faved
    end
  end

  resources :messages do
    collection do
      get :inbox
      get :sent
      delete :destroy_all
    end
  end

  resources :notifications do
    member do
      post :read
    end
  end

  resources :images
  resources :stylesheets
  get '/' => 'channels#index', :as => :root

  get '/react' => 'channels#react'
end
