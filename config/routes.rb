Rails.application.routes.draw do
  resources :letters
  post "/letters/:id/duplicate", to: "letters#duplicate", as: 'duplicate_letter'
  post "/letters/:id/format", to: "letters#format", as: 'format_letter'
  post "/letters/:id/select-legislators", to: "letters#select_legislators", as: 'select_legislator_letter'
  resources :categories
  root 'welcome#index'
  get "/congress_critters", to:"congress_critters#index", as: 'congress_critters'
  get "/districts", to:"districts#index", as: 'districts'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
