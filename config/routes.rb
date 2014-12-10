require "resque_web"
require 'site_constraint'

Fu2::Application.routes.draw do
  mount ResqueWeb::Engine => "/resque"

  resource :session, :controller => :session do
    collection do
      post :authenticate
    end
  end

  resources :users do
    member do
      put :block
      get :activate
      get :password
    end
  end

  scope '(:site_path)' do
    constraints SiteConstraint.new do
      resources :invites do
        member do
          put :approve
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

      resources :notifications do
        member do
          post :read
        end
      end

      resources :images
      get '/' => 'channels#index', :as => :root
    end
  end
end
