Fu2::Application.routes.draw do
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
    end
    member do
      get :posts
    end
    resources :posts
  end

  resources :posts do
    member do
      post :fave
    end
  end


  resources :messages do
    collection do
      get :inbox
      get :sent
      delete :destroy_all
    end
  end

  resources :uploads
  resources :stylesheets
  match 'live' => 'channels#live', :as => :live
  match '/' => 'channels#index', :as => :root
end
