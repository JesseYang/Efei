require 'sidekiq/web'
Rails.application.routes.draw do

  mount Sidekiq::Web, at: "/sidekiq"

  match '/:unique_key' => 'mongoid_shortener/shortened_urls#translate', :via => :get, :constraints => { :unique_key => /~.+/ }
  get '/login', to: 'account/sessions#new', role: "student"
  get '/student_android_app_qr_code', to: 'qrcodes#student_android_app_qr_code'
  get '/student_ios_app_qr_code', to: 'qrcodes#student_ios_app_qr_code'

  get '/students/android_app', to: 'welcome#student_android_app_download'
  get '/students/ios_app', to: 'welcome#student_ios_app_download'
  get '/redirect', to: 'welcome#redirect'

  get "welcome/index"
  get "welcome/student_app"
  get "welcome/app_download"
  get "welcome/app_version"

  match '/' => 'welcome#weixin', :via => :post

  namespace :admin do
    resources :teachers do
    end

    resources :courses do
      member do
        put :toggle_ready
      end
    end

    resources :lessons do
    end

    resources :videos do
    end

    resources :tags do
    end
  end

  match "/weixin_js_signature" => 'application#signature', :via => :get
  namespace :coach do
    resources :students do
    end
    resources :exercises do
    end
  end

  namespace :weixin do
    resources :users do
      collection do
        get :pre_bind
        get :expire
        get :bind_info
      end
      member do
        post :bind
        post :unbind
      end
    end
    resources :exercises do
    end
    resources :records do
    end
    resources :reports do
    end
    resources :courses do
      member do
        get :exercise
        get :record
        get :report
        get :schedule
      end
    end
  end

  namespace :tablet do
    resources :courses do
    end

    resources :teachers do
    end

    resources :lessons do
    end

    resources :videos do
    end

    resources :tags do
    end

    resources :studies do
    end

    resources :learn_logs do
    end

    resources :action_logs do
    end
  end

  namespace :account do
    resources :registrations do
      collection do
        get :reset_email
        post :finish
      end
    end
    resources :sessions do
      collection do
        delete :sign_out
        post :tablet_login
      end
    end
    resources :passwords do
      collection do
        get :edit
        put :update
        post :verify_code
      end
    end
  end

  resources :schools do
  end

  namespace :teacher do
    resources :help do
      collection do
        get :quick_guide
        get :homework_manage
        get :folder_manage
        get :class_manage
        get :stat_check
      end
    end

    resources :feedbacks do
    end

    resources :demos do
    end

    resources :points do
    end

    resources :structures do
    end

    resources :papers do
      collection do
        get :list
        get :modify
      end
      member do
        get :show_one
        get :show_questions
      end
    end

    resources :materials do
      collection do
        get :list
        post :upload_image
        get :upload
      end
      member do
        post :confirm
        post :recover
      end
    end

    resources :resources do
    end

    resources :students do
      member do
        put :move
        put :copy
        get :stat
      end
      collection do
        get :list
      end
    end

    resources :klasses do
      put :rename
    end

    resources :folders do
      member do
        get :chain
      end
    end

    resources :tag_sets

    resources :slides do
    end

    resources :nodes do
      member do
        put :recover
        put :star
        delete :delete
        put :move
        put :rename
        get :list_children
        get :get_folder_id
      end
      collection do
        get :starred
        get :trash
        get :all_shares
        get :search
        get :recent
        get :all_homeworks
        get :all_slides
        get :workbook
      end
    end

    resources :shares do
      member do
        get :stat
        get :settings
        get :generate
      end
    end

    resources :homeworks do
      collection do
        post :create_blank
      end
      member do
        get :stat
        get :generate
        get :settings
        get :export
        put :share
        get :share_info
        put :set_tag_set
        put :set_basic_setting
        post :replace
        post :insert
        put :reorder
        post :copy
        put :combine_questions
      end
    end

    resources :settings do
      member do
        put :update_password
      end
      collection do
        get :colleague_info
        get :teacher_info
      end
    end

    resources :questions do
      collection do
        get :point_list
      end
      member do
        get :ensure_qr_code
        get :stat
        post :replace
        post :insert
        get :export
        put :update_info
      end
    end

    resources :composes do
      collection do
        put :add
        put :remove
        put :clear
        put :confirm
      end
    end
  end

  namespace :student do
    resources :feedbacks
    resources :students do
      collection do
        get :info
        put :rename
        put :change_password
        put :change_email
        put :change_mobile
        post :verify_mobile
      end
    end
    resources :teachers do
      collection do
        get :list
      end
      member do
        put :add_teacher
        put :remove_teacher
        get :list_classes
      end
    end
    resources :notes do
      collection do
        get :note_update_time
        get :export
        post :web_export
        post :batch
        get :list
      end
      member do
        put :update_tag
        put :update_topic_str
        put :update_summary
      end
    end
    resources :questions do
      member do
        post :append_note
      end
      collection do
        get :exercise
        post :answer
        get :check_note
      end
    end
    resources :topics do
    end
    resources :settings do
      member do
        put :update_password
      end
    end
  end

  namespace :school_admin do
    resources :teachers do
      collection do
        post :batch_create
        put :update_password
        get :csv_header
      end
    end
  end

  resources :qrcodes do
  end
  resources :topics do
    collection do
      get :list
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
