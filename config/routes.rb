Rails.application.routes.draw do

  devise_for :users
  root 'static_pages#home'
  get 'home', to: 'static_pages#home'
  get 'help', to: 'static_pages#help'
  get 'about', to: 'static_pages#about'
  get 'contact', to: 'static_pages#contact'

  devise_scope :user do
    get 'signin', to: 'devise/sessions#new'
    get 'signout', to: 'devise/sessions#destroy'
    get 'signup', to: 'devise/registrations#new'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
