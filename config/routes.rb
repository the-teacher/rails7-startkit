# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'demo#index'

  get '/articles_list', to: 'demo#articles_list'
  get '/articles_cache', to: 'demo#articles_cache'
  get '/articles_search', to: 'demo#articles_search'
end
