Rails.application.routes.draw do
  get 'gemini/index'
  get 'line_accounts/new'
  get 'line_accounts/create'
  devise_for :users
  root 'questions#new'

  resources :users, only: [:show]

  resources :line_accounts, only: [:new, :create]

  post '/line/webhook', to: 'line_webhook#callback'

  resources :questions, only: [:new, :create, :index, :show]do
    resources :answers, only: [:create, :index]
    resource  :quiz, only: [:show, :update]  # ←単数形でスッキリ
  end

  get 'gemini', to: 'gemini#index'

  
end