Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get     '/login', to: 'sessions#new'
  post    '/login', to: 'sessions#create'
  delete  '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'edit_basic_all'
    end
    collection do
      post 'import'
      get 'index_attendance'
    end
    resources :attendances, only: [:update] do
      member do
        get 'edit_over_work'
        patch 'update_over_work'
      end
    end
    
  end
  
  resources :bases do
    collection do
      get 'index_area'
    end
  end

end
