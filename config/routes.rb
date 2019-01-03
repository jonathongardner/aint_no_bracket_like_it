# frozen_string_literal: true

Rails.application.routes.draw do
  # resources :brackets
  get 'brackets/:year', to: 'brackets#show', as: "bracket"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
