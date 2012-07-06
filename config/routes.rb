Rails3MongoidDevise::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  
  root :to => "home#index"

  devise_for :users

  resources :users, :only => [:show, :index]

  resources :passets
  
  get "/assets/:uuid/:dims.jpg",
    :controller => "images",
    :action => "serve"

  get "/thumbs/:uuid-:dims.jpg",
    :controller => "images",
    :action => "servethumb"

  get 'uploads/download/:fn' => 'uploads#download'

end
