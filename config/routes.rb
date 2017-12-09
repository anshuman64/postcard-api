Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    # 'Users' routes
    get    'users',          to: 'user#find_user'
    post   'users',          to: 'users#create_user'

    # 'Posts' routes
    get    'posts',          to: 'posts#get_all_posts'
    get    'posts/authored', to: 'posts#get_authored_posts'
    get    'posts/liked',    to: 'posts#get_liked_posts'
    post   'posts',          to: 'posts#create_post'
    delete 'posts/:id',      to: 'posts#destroy_post'

    # 'Likes' routes
    post   'likes',          to: 'likes#create_like'
    delete 'likes/:post_id', to: 'likes#destroy_like'
  end
end
