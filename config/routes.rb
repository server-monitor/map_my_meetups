
require 'resque_web'

# ... edited by app generator
Rails.application.routes.draw do
  resources(:meetup_events) do
    collection do
      get :index
      get :map

      # Hacks...
      get :delete_all
      get :leaflet
    end
  end

  resources :meetup_events, only: [:create]

  root 'meetup_events#map'

  devise_for :users
  resources :users

  mount ActionCable.server => '/cable'

  # ...
  mount ResqueWeb::Engine => '/jobs'
end
