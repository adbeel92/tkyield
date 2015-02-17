Rails.application.routes.draw do

  
  root to: "home#index"

  resources :users , only: [:index]

  resources :tasks

  resources :projects do
  	get 'tasks', on: :collection
  end

  resources :clients

  resources :timesheets do
    get 'toggle_timesheet', on: :collection
  end

  devise_for :users, :controllers => { registrations: 'registrations' }


end
