# frozen_string_literal: true

Rails.application.routes.draw do
  resources :event_instances
  resources :events
  get "welcome/index"
end
