Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    # 'Pusher' routes
    post 'pusher/auth',                     to: 'pusher#auth'

    # 'Users' routes
    get    'users',                         to: 'users#find_user'
    post   'users',                         to: 'users#create_user'
    put    'users',                         to: 'users#edit_user'

    # TODO: test that authored/liked routes work without user_id sent
    # 'Posts' routes
    get    'posts',                         to: 'posts#get_public_posts'
    get    'posts/authored',                to: 'posts#get_my_authored_posts'
    get    'posts/authored/:user_id',       to: 'posts#get_authored_posts'
    get    'posts/liked',                   to: 'posts#get_my_liked_posts'
    get    'posts/liked/:user_id',          to: 'posts#get_liked_posts'
    get    'posts/followed',                to: 'posts#get_followed_posts'
    get    'posts/received',                to: 'posts#get_received_posts'
    post   'posts',                         to: 'posts#create_post'
    delete 'posts/:id',                     to: 'posts#destroy_post'

    # 'Likes' routes
    post   'likes',                         to: 'likes#create_like'
    delete 'likes/:post_id',                to: 'likes#destroy_like'

    # 'Flags' routes
    post   'flags',                         to: 'flags#create_flag'
    delete 'flags/:post_id',                to: 'flags#destroy_flag'

    # 'Follows' routes
    post   'follows',                       to: 'follows#create_follow'
    delete 'follows/:followee_id',          to: 'follows#destroy_follow'

    # 'Friendships' routes
    get    'friendships/accepted',          to: 'friendships#get_friends'
    get    'friendships/sent',              to: 'friendships#get_sent_requests'
    get    'friendships/received',          to: 'friendships#get_received_requests'
    post   'friendships',                   to: 'friendships#create_friend_request'
    put    'friendships/accept',            to: 'friendships#accept_friend_request'
    delete 'friendships/:user_id',          to: 'friendships#destroy_friendship'

    # 'Messages' routes
    post   'messages',                      to: 'messages#create_message'
  end
end
