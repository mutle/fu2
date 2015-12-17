require "resque_web"
require "site_constraint"

Fu2::Application.routes.draw do
  mount ResqueWeb::Engine => "/resque", as: "resque"

  resource :session, :controller => :session do
    collection do
      post :authenticate
    end
  end

  namespace :api do
    resources :sites
  end

  scope '(:site_path)' do
    constraints SiteConstraint.new do
      namespace :api do
        resources :channels do
          resources :posts
        end
        resources :posts do
          collection do
            post :search
            get :advanced_search
          end
          member do
            post :fave
          end
        end

        resource :users do
        end

        resources :users do
          collection do
            get :current
          end
          member do
            get :stats
          end
        end

        resources :notifications do
          member do
            post :read
          end
          collection do
            get :unread
            get :unread_users
            get :counters
          end
        end

        resources :sites
        resources :images
        resources :emojis

        get 'stats/websockets' => "stats#websockets"
        get 'info' => "api#info"
      end

      resources :users do
        member do
          put :block
          get :activate
          get :password
        end
      end
      get '/settings' => 'users#show', as: :settings

      resources :invites do
        member do
          put :approve
        end
      end

      resources :search, :controller => :search do
        collection do
          get ':query/:sort' => "search#index"
        end
      end

      resources :channels do
        collection do
          get :search
          get :channel_names
          get :all
        end
      end

      resources :notifications

      get '/' => 'channels#index', :as => :root
    end
  end
end
