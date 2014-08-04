Betaman::Application.routes.draw do

  get "dashboard/index"

  get '/users/select', to: 'users#select', as: 'user_select'

  get '/users/:id/betas', to: 'users#betas', as: 'user_betas'
  get '/users/:id/add_beta/:beta_id', to: 'users#add_beta', as: 'user_add_beta'
  get '/users/:id/remove_beta/:beta_id', to: 'users#remove_beta', as: 'user_remove_beta'

  get '/users/emails', to: 'users#emails', as: 'users_emails'

  get '/users/:id/edit_participation/:participation_id', to: 'users#edit_participation', as: 'user_edit_participation'
  post '/users/:id/edit_participation/:participation_id', to: 'users#update_participation', as: 'user_edit_participation'
  get '/users/:id/toggle_participation/:participation_id', to: 'users#toggle_participation', as: 'user_toggle_participation'

  get '/betas/:id/add_select_users', to: 'betas#add_select_users', as: 'beta_add_select_users'
  post '/betas/:id/add_multiple_users', to: 'betas#add_multiple_users', as: 'beta_add_multiple_users'
  get '/betas/:id/add_list_subscribers/:list_id', to: 'betas#add_list_subscribers', as: 'beta_add_list_subscribers'
  get '/betas/:id/add_list/:list_id', to: 'betas#add_list', as: 'beta_add_list'
  get '/betas/:id/remove_list', to: 'betas#remove_list', as: 'beta_remove_list'
  get '/betas/:id/add_user/:user_id', to: 'betas#add_user', as: 'beta_add_user'
  get '/betas/:id/remove_user/:user_id', to: 'betas#remove_user', as: 'beta_remove_user'
  get '/betas/:id/users', to: 'betas#users', as: 'beta_users'
  get '/betas/:id/users_external', to: 'betas#users_external', as: 'beta_users_external'
  get '/betas/:id/join', to: 'betas#join', as: 'beta_join'
  get '/betas/:id/leave', to: 'betas#leave', as: 'beta_leave'

  get '/lists/:id/sync_to_intern', to: 'lists#sync_to_intern', as: 'list_sync_to_intern'
  get '/lists/:id/users', to: 'lists#users', as: 'list_users'
  get '/lists/:id/add_select_users', to: 'lists#add_select_users', as: 'list_add_select_users'
  post '/lists/:id/add_multiple_users', to: 'lists#add_multiple_users', as: 'list_add_multiple_users'
  get '/lists/:id/subscribe_user/:user_id',   to: 'lists#subscribe_user',   as: 'list_subscribe_user'
  get '/lists/:id/unsubscribe_user/:user_id', to: 'lists#unsubscribe_user', as: 'list_unsubscribe_user'

  resources :users
  resources :betas
  resources :lists
  resources :companies

  root to: 'static_pages#home'
  match '/help', to: 'static_pages#help'
  get "static_pages/help"

  match '/dashboard', to:'dashboard#index'

  match '/auth/:provider/callback', :to => 'session#callback'
  match '/auth/failure', :to => 'session#failure'
  match '/auth/:provider/failure', :to => 'session#failure'
  match '/auth/failure', :to => 'session#failure'


  namespace :admin do
    get '/users/duplicate_emails', controller: 'duplicate_emails', as: 'duplicate_emails'
    get '/users/update_roles', controller: 'update_roles', as: 'update_roles'
    get '/betas/sync_downloads', controller: 'sync_downloads', as: 'sync_downloads'
    get '/betas/sync_lists', controller: 'sync_lists', as: 'sync_lists'
    get '/betas/check', controller: 'check', as: 'check'
    get '/betas/inactive_participations', controller: 'inactive_participations', as: 'inactive_participations'
    get '/diary/user/:user_id', to: 'diary#user', as: 'diary_user'
    get '/diary', to: 'diary#index', as: 'diary'
    get '', to: 'dashboard#index', as: '/'
    resources :users 
    resources :betas
    resources :companies

    resources :milestones do
      member do
        get '/add_beta/:beta_id',    to: 'milestones#add_beta',    as: 'add_beta'
        get '/remove_beta/:beta_id', to: 'milestones#remove_beta', as: 'remove_beta'
      end
    end

    resources :groups do
      member do
        post 'upload'
        get '/merge_users', to: 'groups#merge_users', as: 'merge_users'
        get '/groups/:id/users', to: 'groups#users', as: 'users'
        get '/groups/:id/add_user/:user_id', to: 'groups#add_user', as: 'add_user'
        get '/groups/:id/remove_user/:user_id', to: 'groups#remove_user', as: 'remove_user'
        get '/groups/:id/add_select_users',  to: 'groups#add_select_users', as: 'select_users'
        get '/groups/:id/add_to_beta',  to: 'groups#add_to_beta', as: 'add_to_beta'
        post '/groups/:id/add_multiple_users',  to: 'groups#add_multiple_users', as: 'add_multiple_users'
      end
    end
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
