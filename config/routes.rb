# frozen_string_literal: true

Rails.application.routes.draw do
  resources :staff_profiles
  resources :approvals
  resources :departments
  root "welcome#index"
  get "welcome/index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get "sign_in", to: "devise/sessions#new", as: :new_user_session
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end

  resources :event_requests
  resources :recurring_events
  resources :travel_requests
  resources :absence_requests
end
