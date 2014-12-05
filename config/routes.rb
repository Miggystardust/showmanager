Rails3MongoidDevise::Application.routes.draw do

  resources :entry_techinfo

  resources :entries

  resources :apps do
    member do
      get :dashboard
      get :express_checkout
      get :payment_cancel
      get :payment_paid
    end

     resources :entries

     # /apps/:app_id/entry_techinfo(.:format)
     resources :entry_techinfo
  end

  root :to => "home#index"

  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end

  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks"}

  resources :users, :only => [:show, :index, :edit, :update, :destroy]
  resources :users do 
    member do
      get :become
    end
  end

  resources :troupes do
    member do 
      post :join
      post :leave
    end
  end

  # bhof routes
  get "/appdashboard", :to => "bhof#dashboard"

  resources :bhof, :only => [:show, :index]

  resources :invitation, :only => [ :index, :destroy, :create ]

  # overriding devise here to deal with users w/o passwords
  get "/settings/edit",
    :controller => "settings",
    :action => "edit";

  post "/settings/update",
    :controller => "settings",
    :action => "update";

  post "/passets/new",
    :controller => "passets",
    :action => "create";

  post "/acts/new",
    :controller => "acts",
    :action => "create";

  # override 
  get "/acts/self",
    :controller => "acts",
    :action => "index",
    :id => "self";

  resources :acts do
    collection do
      get :adminindex
    end
  end

  resources :passets do
   collection do
     get :search
     get :adminindex
     get :index
   end
  end

  resources :shows do
   member do
      get 'perfindex'
      get 'items'
      get 'show_items'
      get 'download'
      get 'refresh_act_times'
   end
  end

  resources :show_items

  # this is a non-standard endpoint thanks to
  # datatables

  post "/show_items/update_seq",
    :controller => "show_items",
    :action => "update_seq"

  post "/show_items/:id/move.json",
    :controller => "show_items",
    :action => "move"

  get "/s/:uuid-:dims.jpg",
    :controller => "images",
    :action => "servethumb"

  get "/sf/:uuid.jpg",
    :controller => "images",
    :action => "servefull"

  get "/sf/:uuid",
    :controller => "images",
    :action => "servefull"

  get "/thumbs/:uuid-:dims.jpg",
    :controller => "images",
    :action => "servethumb"


  get 'uploads/download/:fn' => 'uploads#download'
  get 'uploads/download/:fn.:discard' => 'uploads#download'

  # policy wonking
  get '/about/privacy'
  get '/about/tos'
  get '/about/support'

end
