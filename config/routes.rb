Rails.application.routes.draw do
  # Gemini関連
  get 'gemini', to: 'gemini#index'

  # LINE連携関連
  resources :line_accounts, only: [:new]
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
    post 'save_quiz_and_answer', on: :member
    delete :bulk_delete, on: :collection
  end

  # GAS連携
  namespace :api do
    namespace :v1 do
      namespace :line do
        get 'quiz_today', to: 'notifier#quiz_today'
      end
    end
  end

  resources :admin, only: [:new, :create]

  resources :quizzes, only: [:index] do
    collection do
      post :update_send_to_line
      post :reset_send_to_line
      post :manage
    end
  end

end