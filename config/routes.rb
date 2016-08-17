Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'static_pages#home'
  get 'feedback' => 'static_pages#feedback'
  get 'signup' => 'users#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  resources :users do
    member do
      patch 'follow_top_sites'
    end
  end
  resources :feeds
  resources :opml, only: [:new, :create]
  resources :password_resets
  resources :sessions
  resources :subscriptions
  get 'billing/expired' => 'billing#expired'
  get 'billing/checkout' => 'billing#checkout'
  get 'billing/confirm' => 'billing#confirm'
  get 'billing/finalize' => 'billing#finalize'
  get 'opml/export' => 'opml#export'
end
