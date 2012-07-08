Rails3MongoidDevise::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  
  root :to => "home#index"

  devise_for :users
  resources :users, :only => [:show, :index, :edit]

  post "/passets/new",
    :controller => "passets", 
    :action => "create";

  resources :passets

  get "/s/:uuid-:dims.jpg",
    :controller => "images",
    :action => "servethumb"

  get "/sf/:uuid.jpg",
    :controller => "images",
    :action => "servefull"

  get "/thumbs/:uuid-:dims.jpg",
    :controller => "images",
    :action => "servethumb"

  get 'uploads/download/:fn' => 'uploads#download'

end
