# frozen_string_literal: true

Rails.application.routes.draw do
  get 'unique_brackets/available', to: 'unique_brackets#available', as: "unique_brackets_available"
  resources :unique_brackets, only: [:show, :index]
  resources :saved_brackets
  # resources :brackets
  get 'brackets/:year', to: 'brackets#show', as: "bracket"
  get 'brackets/:year/initial', to: 'brackets#initial', as: "initial_bracket"
  get 'brackets/stats/:game_number', to: 'brackets#stats', as: "bracket_stats"

  mount Slots::Engine => '/auth'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
