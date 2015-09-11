Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :login_account, only: :create
      resources :time_stations, only: :create
      resources :users, only: :index
    end
  end

  root to: "home#index"
  get "registration", to: "home#registration"
  post "registration", to: "home#register"

  # constraints(Subdomain) do
  scope ':route' do
    get '/', to: "dashboard#index", as: "dashboard"
    resources :users, only: [:index, :new, :edit, :create, :update], path: "collaborators" do
      get 'archives', to: 'users#archives', on: :collection
      get 'show_user_project', to: 'users#projects', on: :member
      patch 'update_user_project', to: 'users#update_projects', on: :member
      get 'resend_confirmation', to: 'users#resend_confirmation', on: :member
      put 'archive', to: 'users#archive', on: :member
      put 'unarchive', to: 'users#unarchive', on: :member
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
    resources :time_stations
    namespace :reports do
      get 'list', to: 'reports#index'
      get 'dash', to: 'reports#dash'
      get 'tables', to: 'reports#tables'
      get 'clients_excel', to: 'reports#clients_excel'
      get 'projects_excel', to: 'reports#projects_excel'
      get 'collaborators_excel', to: 'reports#collaborators_excel'
      get '/user_project/:user_id/:project_id', to: 'user_project#show', as: "user_project"
      resources :on_time, only: :index do 
        get 'daily_excel', to: 'on_time#daily_excel', on: :collection
        get 'summary_excel', to: 'on_time#summary_excel', on: :collection
      end
      resources :projects, only: :show do
        get 'project_excel', to: 'projects#project_excel'
      end
      resources :users, only: :show do
        get 'user_excel', to: 'users#user_excel'
      end
      resources :clients, only: :show do
        get 'client_excel', to: 'clients#client_excel'
      end
    end
    devise_for :users, :controllers => { :sessions => 'user_device/sessions', :passwords => 'user_device/passwords', :registrations => 'user_device/registrations', :confirmations => 'user_device/confirmations' }
    devise_scope :user do
      patch "/confirm" => "user_device/confirmations#confirm"
    end
  end

end
