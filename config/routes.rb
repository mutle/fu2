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
      get :desktop
      get :live
    end
    resources :posts
  end

  resources :posts do
    member do
      post :fave
      post :unread
    end
  end


  resources :messages do
    collection do
      get :inbox
      get :sent
      delete :destroy_all
    end
  end

  resources :images
  resources :stylesheets
  get '/' => 'channels#index', :as => :root
end
