# frozen_string_literal: true

Rails.application.routes.draw do
  mount Slots::Engine => '/auth'
  # resources :brackets
  get 'brackets/:year', to: 'brackets#show', as: "bracket"
  get 'brackets/:year/initial', to: 'brackets#initial', as: "initial_bracket"
  get 'brackets/stats/:game_number', to: 'brackets#stats', as: "bracket_stats"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
