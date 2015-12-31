Rails.application.routes.draw do
  root 'static_pages#home'
  get 'signup' => 'users#new'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'
  resources :users do
    member do
      patch 'update_topics'
    end
  end
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :feeds,           only: [:index, :new, :create, :show]
  resources :subscriptions,   only: [:index, :create, :edit,
                                     :update, :destroy]
  resources :opml,            only: [:new, :create]
  get 'billing/expired' => 'billing#expired'
  get 'billing/checkout' => 'billing#checkout'
  get 'billing/confirm' => 'billing#confirm'
  get 'billing/finalize' => 'billing#finalize'
  get 'feedback' => 'static_pages#feedback'
  get 'next' => 'subscriptions#next'
  get 'opml/export' => 'opml#export'
end
