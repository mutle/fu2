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
            post :read
          end
        end

        resources :sites
        resources :images
        resources :emojis

        get 'stats/websockets' => "stats#websockets"
        get 'info' => "api#info"
      end

      Fu2::REACT_ROUTES.each do |route|
        if route.is_a?(Array)
          if route.size > 2
            get route[0] => "react##{route[2]}", as: route[1]
          else
            get route[0] => "react#index", as: route[1]
          end
        else
          get route => "react#index"
        end
      end

      resources :users do
        member do
          get :activate
        end
      end
    end
  end
end
