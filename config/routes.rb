Rails.application.routes.draw do
  resources :letters
  post "/letters/:id/duplicate", to: "letters#duplicate", as: 'duplicate_letter'
  resources :categories
  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
