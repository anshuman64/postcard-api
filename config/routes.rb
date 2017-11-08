Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    # 'Posts' routes
    get    'posts',     to: 'posts#index'
    post   'posts',     to: 'posts#create'
    get    'posts/:id', to: 'posts#show'
    delete 'posts/:id', to: 'posts#destroy'

    # 'Likes' routes
    post   'likes',     to: 'likes#create'
    delete 'likes/:id', to: 'likes#destroy'
  end
end
