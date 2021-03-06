RubyTask::Application.routes.draw do
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
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  resources :home

  # general routes
  get "/login" => "sessions#new", as: :login
  post "/home/search" => "home#search"

  # project routes
  get "/projects/:organisation_id/new" => "projects#new"
  post "/projects/:organisation_id/create" => "projects#create"
  get "/projects/:organisation_id/:project_id/leave" => "projects#leave"
  get "/projects/:organisation_id/:project_id/join" => "projects#join"
  get "/projects/:organisation_id/:project_id/edit" => "projects#edit"
  get "/projects/:organisation_id/:project_id/dialog_add_member" => "projects#dialog_add_member"
  post "/projects/:organisation_id/:project_id/edit_do" => "projects#edit_do"
  post "/projects/:organisation_id/:project_id/add_member" => "projects#add_member"
  get "/projects/:organisation_id/:project_id" => "projects#show", as: :project_view

  # organisation routes
  get "/organisations/new" => "organisations#new"
  post "/organisations/create" => "organisations#create"
  get "/organisations/dialog" => "organisations#dialog"
  get "/organisations/:id/dialog_add_member" => "organisations#dialog_add_member"
  match "/organisations/:id/edit" => "organisations#edit", as: :organisation_edit
  match "/organisations/:id/join" => "organisations#join"
  match "/organisations/:id/leave" => "organisations#leave"
  post "/organisations/edit_do" => "organisations#edit_do", as: :organisation_tmp
  match "/organisations/:id" => "organisations#show", as: :organisation_view
  get "/invite/:id/:type/:name" => "home#invite"

  # Tasks
  get "/mytasks" => "tasks#index"
  get "/tasks/:organisation/:project/new" => "tasks#new"
  post "/tasks/:organisation/:project/create" => "tasks#create"
  get "/tasks/:organisation/:project/new/dialog_add_member" => "tasks#dialog_add_member"
  get "/tasks/:organisation/:project/:owner/:task/:target/edit" => "tasks#edit"
  get "/tasks/:organisation/:project/:owner/:task/edit" => "tasks#edit"
  post "/tasks/:organisation/:project/:owner/:task/:target/update" => "tasks#update"
  post "/tasks/:organisation/:project/:owner/:task/update" => "tasks#update"
  match "/tasks/:organisation/:project/:owner/:task/:target/destroy" => "tasks#destroy"
  match "/tasks/:organisation/:project/:owner/:task/destroy" => "tasks#destroy"
  get "/tasks/:organisation/:project/:owner/:task/:target/edit/dialog_add_member" => "tasks#dialog_add_member"
  get "/tasks/:organisation/:project/:owner/:task/edit/dialog_add_member" => "tasks#dialog_add_member"
  get "/tasks/:organisation/:project/:owner/:task/:target/complete" => "tasks#complete"
  get "/tasks/:organisation/:project/:owner/:task/complete" => "tasks#complete"
  get "/tasks/:organisation/:project/:owner/:task/:target" => "tasks#show"
  get "/tasks/:organisation/:project/:owner/:task" => "tasks#show"
  



  match "/auth/:provider/callback" => "sessions#create"
  match "/auth/failure" => "sessions#failure"

end
