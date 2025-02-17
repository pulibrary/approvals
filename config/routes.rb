# frozen_string_literal: true

Rails.application.routes.draw do
  root "welcome#index"
  get "welcome/index"
  mount HealthMonitor::Engine, at: "/"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get "sign_in", to: "devise/sessions#new", as: :new_user_session
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  # Turn off access to pages we are not currently using
  # resources :recurring_events

  resources :travel_requests, except: [:index] do
    member do
      get "review"
      get "comment"
      put "decide"
    end
  end

  resources :absence_requests, except: [:index] do
    member do
      get "review"
      get "comment"
      put "decide"
    end
  end

  resources :delegates do
    member do
      get "assume"
    end
    collection do
      get "cancel"
      get "to_assume"
    end
  end

  get "my_requests", action: :my_requests, controller: "requests"
  get "my_approval_requests", action: :my_approval_requests, controller: "requests"
  get "reports", action: :reports, controller: "requests"
end
