Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    # 'Users' routes
    post   'users',                   to: 'users#create'

    # 'Posts' routes
    get    'posts',                   to: 'posts#index'
    post   'posts',                   to: 'posts#create'
    delete 'posts/:id',               to: 'posts#destroy'

    # 'Likes' routes
    post   'likes',                   to: 'likes#create'
    delete 'likes/:user_id/:post_id', to: 'likes#destroy'
  end
end
