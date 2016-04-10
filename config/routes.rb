Rails.application.routes.draw do
  resources :courses
  resources :locations

  get "/metrics", to: "metrics#index", as: 'metrics'

  root to: "dashboards#to_do"

  get  '/sign_in',  to: 'sessions#new',     as: :sign_in
  post '/sign_in',  to: 'sessions#create'
  get  '/sign_out', to: 'sessions#destroy', as: :sign_out

  scope :github do
    get "/authorize",     to: "sessions#gh_authorize",     as: :gh_authorize
    get "/authenticate",  to: "sessions#gh_authenticate",  as: :gh_authenticate
  end

  scope :mantras do
    get "/",        to: "mantras#index"
    get "/random",  to: "mantras#random"
    get "/refresh", to: "mantras#refresh"
  end

  resources :cohorts do
    member do
      get 'gh_refresh'
      get 'manage'
      get 'todos'
      post 'generate_invite_code'
      post 'generate_events'
    end
    resources :events,      only: [:create]
    resources :assignments, only: [:create]
    resources :memberships, only: [:create]
  end

  resources :memberships, only: [:show, :destroy, :update] do
    post :toggle_active, on: :member
    post :toggle_admin, on: :member
  end

  resources :taggings, only: [:create, :destroy]

  resources :users, param: :user do
    member do
      get "is_registered", action: :is_registered?
      get 'gh_refresh'
      post 'regenerate_api_token'
    end
  end

  resources :assignments, only: [:show, :update, :destroy] do
    get "issues", to: "assignments#issues", as: :issues
    resources :submissions, only: [:create]
  end

  resources :events,        only: [:show, :update, :destroy] do
    resources :attendances, only: [:create]
  end

  resources :submissions,   only: [:update, :destroy]
  resources :attendances,   only: [:update, :destroy] do
    put "self_take", on: :member
  end
  resources :observations,  only: [:create, :destroy]


  namespace :api do
    resource :user, only: [:show]
    get 'send_api_token'
    post 'observations/from_outcomes'
    resources :cohorts, only: [:index, :show] do
      resources :memberships, only: [:index]
    end
  end
end
