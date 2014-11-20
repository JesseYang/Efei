Rails.application.routes.draw do
  match '/:unique_key' => 'mongoid_shortener/shortened_urls#translate', :via => :get, :constraints => { :unique_key => /~.+/ }

  get "welcome/index"

  namespace :account do
    resources :registrations do
      collection do
        get :reset_email
      end
    end
    resources :sessions do
      collection do
        delete :sign_out
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

  namespace :teacher do

    resources :widgets do
    end

    resources :folders do
      member do
        put :rename
        put :move
        get :list
        get :chain
        put :recover
        delete :delete
      end
      collection do
        get :trash
        get :search
      end
    end

    resources :tag_sets

    resources :homeworks do
      member do
        get :generate
        get :get_folder_id
        get :settings
        get :export
        put :rename
        put :move
        put :share
        put :share_all
        put :set_tag_set
        put :recover
        delete :delete
      end
      collection do
        get :recent
        get :all
      end
    end

    resources :settings do
      member do
        put :update_password
      end
    end

    resources :groups do
      member do
        post :update_select
      end
    end

    resources :questions do
      member do
        get :ensure_qr_code
        get :stat
        post :replace
        post :insert
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
    resources :notes do
      collection do
        get :note_update_time
        get :export
        post :batch
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
