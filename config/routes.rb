require "resque_web"
require 'site_constraint'

Fu2::Application.routes.draw do
  get 'search/show'

  mount ResqueWeb::Engine => "/resque"

  scope '(:site_path)' do
    constraints SiteConstraint.new do
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

      resources :invites do
        member do
          put :approve
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
