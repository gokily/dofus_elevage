Rails.application.routes.draw do

  devise_for :users
  root 'static_pages#home'
  get 'home', to: 'static_pages#home'
  get 'help', to: 'static_pages#help'
  get 'about', to: 'static_pages#about'
  get 'contact', to: 'static_pages#contact'

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
    get 'sign_out', to: 'devise/sessions#destroy'
    get 'sign_up', to: 'devise/registrations#new'
  end
  resources :mounts do
    collection do
      get :pregnant
      post :birth_create
    end
    member do
      get :breed
      get :mate
      get :birth
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
