Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'static_pages#root'

  namespace :api, defaults: { format: :json } do
    post 'session/auth',      to: 'sessions#auth'
    post 'session/validate/', to: 'sessions#validate'
  end
end
