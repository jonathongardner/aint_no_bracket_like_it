# frozen_string_literal: true

Rails.application.routes.draw do
  post 'unique_brackets/available', to: 'unique_brackets#available', as: "unique_brackets_available"
  resources :unique_brackets, only: [:show, :index]
  resources :saved_brackets

  resources :users, only: [:create] do
    collection do
      patch :validate_email
      get :forgot_password
      patch :reset_password
    end
  end
  put :users, controller: :users, action: :update
  patch :users, controller: :users, action: :update

  namespace :admin do
    resources :users, only: [:index] do
      patch :approve
      get :email_confirmation
      get :forgot_password
    end
  end
  # resources :brackets
  get 'brackets/:year', to: 'brackets#show', as: "bracket"
  get 'brackets/:year/initial', to: 'brackets#initial', as: "initial_bracket"
  get 'brackets/stats/:game_number', to: 'brackets#stats', as: "bracket_stats"

  mount Slots::Engine => '/auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
