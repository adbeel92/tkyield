Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :time_stations, only: :create
      resources :users, only: :index
    end
  end
  root to: "home#index"
  resources :users, only: [:index, :new, :edit, :create, :update], path: "collaborators" do
    get 'show_user_project', to: 'users#projects', on: :member
    patch 'update_user_project', to: 'users#update_projects', on: :member
    get 'resend_confirmation', to: 'users#resend_confirmation', on: :member
  end
  resources :tasks
  resources :clients
  resources :projects do
    get 'tasks', on: :collection
  end
  resources :teams do
    get 'collaborators', on: :collection
  end
  resources :timesheets, except: [:show, :new, :edit] do
    get 'toggle_timesheet', on: :member
  end
  namespace :reports do
    get 'dash', to: 'reports#dash'
    get 'list', to: 'reports#index'
    get 'clients_excel', to: 'reports#clients_excel'
    get 'projects_excel', to: 'reports#projects_excel'
    get 'collaborators_excel', to: 'reports#collaborators_excel'
    get '/user_project/:user_id/:project_id', to: 'user_project#show', as: "user_project"
    resources :on_time, only: :index
    resources :projects, only: :show
    resources :users, only: :show
    resources :clients, only: :show
  end
  resources :time_stations
  # resources :reports


  devise_for :users, :controllers => { :passwords => 'user_device/passwords', :confirmations => 'user_device/confirmations' }
  devise_scope :user do
    patch "/confirm" => "user_device/confirmations#confirm"
  end

end
