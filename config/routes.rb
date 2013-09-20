Betaman::Application.routes.draw do

  get "dashboard/index"

  resources :users
  resources :betas

  get '/users/:id/betas', to: 'users#betas', as: 'user_betas'


  get '/betas/:id/rmuser', to: 'betas#rmuser', as: 'beta_rmuser'
  get '/betas/:id/users', to: 'betas#users', as: 'beta_users'

  root to: 'static_pages#home'
  match '/help', to: 'static_pages#help'
  get "static_pages/help"

  match '/dashboard', to:'dashboard#index'

  match '/auth/:provider/callback', :to => 'session#callback'
  match '/auth/failure', :to => 'session#failure'
  match '/auth/:provider/failure', :to => 'session#failure'
  match '/auth/failure', :to => 'session#failure'


  namespace :admin do
    resources :users
    resources :betas
    resources :companies
    get '', to: 'dashboard#index', as: '/'
    #get 'users', to: 'user#index', as: '/'
    #match '', to: 'dashboard#index'
    #match 'admin/users', to: 'dashboard#index'
  end
  
  match ':controller/:action' => ":controller#:action"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
