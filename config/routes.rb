Rails.application.routes.draw do
  # Gemini関連
  get 'gemini', to: 'gemini#index'

  # LINE連携関連
  resources :line_accounts, only: [:new, :create]
  post '/line/webhook', to: 'line_webhook#callback'

  # Deviseユーザー認証
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # トップページ
  root 'questions#new'

  # ユーザープロフィール
  resources :users, only: [:show]

  # 質問・回答・クイズ
  resources :questions, only: [:new, :create, :index, :show] do
    resources :answers, only: [:create, :index]
    resource  :quiz, only: [:show, :update]
  end
end