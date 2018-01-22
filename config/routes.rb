Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    # 'Users' routes
    get    'users',                   to: 'users#find_user'
    post   'users',                   to: 'users#create_user'
    put    'users',                   to: 'users#edit_user'

    # 'Posts' routes
    get    'posts',                   to: 'posts#get_all_posts'
    get    'posts/authored',          to: 'posts#get_authored_posts'
    get    'posts/liked',             to: 'posts#get_liked_posts'
    get    'posts/authored/:user_id', to: 'posts#get_authored_posts'
    get    'posts/liked/:user_id',    to: 'posts#get_liked_posts'
    get    'posts/followed/',         to: 'posts#get_followed_posts'
    post   'posts',                   to: 'posts#create_post'
    delete 'posts/:id',               to: 'posts#destroy_post'

    # 'Likes' routes
    post   'likes',                   to: 'likes#create_like'
    delete 'likes/:post_id',          to: 'likes#destroy_like'
    
    # 'Flags' routes
    post   'flags',                   to: 'flags#create_flag'
    delete 'flags/:post_id',          to: 'flags#destroy_flag'

    # 'Follows' routes
    post   'follows',                 to: 'follows#create_follow'
    delete 'follows/:followee_id',    to: 'follows#destroy_follow'
  end
end
