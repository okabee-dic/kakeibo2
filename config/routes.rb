Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    #passwords:     'users/passwords',
    registrations: 'users/registrations',
    sessions:      'users/sessions',
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  
  devise_scope :user do
    post 'users/check_username' => 'users/registrations#username_check' , defaults: { format: :json }
    post 'users/oauth_registration' => 'users/registrations#oauth_registration'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  
  root 'pages#index'
  
  resources :books do
    resources :stores, except: [:new, :edit]
    resources :monthlyinputs, except: [:new, :edit]
    resources :incomes, only: [:create, :update, :destroy]
    resources :receipts, only: [:create, :update, :destroy]
    resource :graphs, only: [:index] do
      get '/', to: 'graphs#index'
      get 'linegraph', to: 'graphs#linegraph' 
      get 'linegraph/:year/:month', to: 'graphs#linegraph' , as: 'linegraph_in_month'    
    end
    collection do
      get ':id/edit/:year/:month', to: 'books#edit', as: 'edit_book_in_month'
    end
  end
  
  get 'index', to: 'pages#index'
  get 'users/send_confirm', to: 'pages#send_confirm'
  
  # admin menu
  get 'admin/genres', to: 'admin#genres'
  post 'admin/genre', to: 'admin#genre_add', as: 'admin_genre_create'
  patch 'admin/genre/:id', to: 'admin#genre_update', as: 'admin_genre'
  delete 'admin/genre/:id', to: 'admin#genre_destroy'
  
  
end
