Rails.application.routes.draw do

  scope :path => '/api/v1/', :module => "api_v1", :as => 'v1', :defaults => { :format => :json } do
    resources :appointments
  end

  post 'pay2go/return'
  post 'pay2go/notify'

  devise_for :users, controllers: {omniauth_callbacks: 'users/omniauth_callbacks'}

  resources :users do
    member do
      get :classes
      get :changepassword
      get :remark
      get :editprofile
      get :mytutor
    end
    resources :orders do
      member do
        post :checkout_pay2go
      end
    end
    resources :available_section, controller: 'user_available_sections'
    member do
      get 'profile'
    end
  end

  resources :teachers do
    member do
      get 'classes' => 'teachers#classes'
      get 'profile' => 'teachers#profile'
      get 'calendar' => 'teachers#calendar'
      get 'introduce' => 'teachers#introduce'
      get 'price' => 'teachers#price'
      get 'education' => 'teachers#education'
      get 'youtube' => 'teachers#youtube'
      get 'gathering' => 'teachers#gathering'
    end
    resources :available_section
  end

  resources :appointments do
    resources :evalutions
  end

  resources :student_reservation do
  end
  resources :teacher_calendars do
    get 'teacher_available_section' => 'teacher_calendars#teacher_available_section'
    get 'booked_section' => 'teacher_calendars#booked_section'
  end

  get  'apply_teacher'=> "welcome#apply_teacher"
  root 'welcome#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
