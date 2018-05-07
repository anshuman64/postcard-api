Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    # 'Pusher' routes
    post   'pusher/auth',              to: 'pusher#auth'

    # 'Users' routes
    get    'users',                    to: 'users#find_user'
    post   'users',                    to: 'users#create_user'
    put    'users',                    to: 'users#edit_user'
    put    'users/avatar',             to: 'users#edit_avatar'

    # TODO: test that authored/liked routes work without user_id sent
    # 'Posts' routes
    get    'posts',                    to: 'posts#get_received_posts'
    get    'posts/authored',           to: 'posts#get_client_authored_posts'
    get    'posts/authored/:user_id',  to: 'posts#get_user_authored_posts'
    get    'posts/liked',              to: 'posts#get_client_liked_posts'
    post   'posts',                    to: 'posts#create_post'
    delete 'posts/:id',                to: 'posts#destroy_post'


    # BACKWARDS COMPATABILITY: START
    get    'posts_new',                    to: 'posts#get_received_posts'
    get    'posts_new/authored',           to: 'posts#get_client_authored_posts'
    get    'posts_new/authored/:user_id',  to: 'posts#get_user_authored_posts'
    get    'posts_new/liked',              to: 'posts#get_client_liked_posts'
    get    'posts_new/liked/:user_id',     to: 'posts#get_user_liked_posts'
    # BACKWARDS COMPATABILITY: END


    # 'Likes' routes
    post   'likes',                    to: 'likes#create_like'
    delete 'likes/:post_id',           to: 'likes#destroy_like'

    # 'Flags' routes
    post   'flags',                    to: 'flags#create_flag'
    delete 'flags/:post_id',           to: 'flags#destroy_flag'

    # NOTE: Follows are deprecated
    # 'Follows' routes
    # post   'follows',                  to: 'follows#create_follow'
    # delete 'follows/:followee_id',     to: 'follows#destroy_follow'

    # 'Blocks' routes
    get    'blocks',                   to: 'blocks#get_blocked_users'
    post   'blocks',                   to: 'blocks#create_block'
    delete 'blocks/:blockee_id',       to: 'blocks#destroy_block'

    # 'Friendships' routes
    get    'friendships/accepted',     to: 'friendships#get_friends'
    get    'friendships/sent',         to: 'friendships#get_sent_requests'
    get    'friendships/received',     to: 'friendships#get_received_requests'
    post   'friendships/contacts',     to: 'friendships#get_friends_from_contacts'
    post   'friendships',              to: 'friendships#create_friend_request'
    put    'friendships/accept',       to: 'friendships#accept_friend_request'
    delete 'friendships/:user_id',     to: 'friendships#destroy_friendship'

    # 'Messages' routes
    get    'messages/direct/:user_id', to: 'messages#get_direct_messages'
    get    'messages/group/:group_id', to: 'messages#get_group_messages'
    post   'messages/direct',          to: 'messages#create_direct_message'
    post   'messages/group',           to: 'messages#create_group_message'

    # 'Circles' routes
    get    'circles',                  to: 'circles#get_circles'
    post   'circles',                  to: 'circles#create_circle'
    delete 'circles/:id',              to: 'circles#destroy_circle'

    # 'Groups' routes
    get    'groups',                  to: 'groups#get_groups'
    post   'groups',                  to: 'groups#create_group'
    post   'groups/add',              to: 'groups#create_grouplings'
    put    'groups',                  to: 'groups#edit_group'
    delete 'groups/:id',              to: 'groups#destroy_group'
    delete 'groups/:id/:user_id',     to: 'groups#destroy_groupling'

    # 'Contacts' routes
    post   'contacts',                to: 'contacts#get_contacts_with_accounts' # NOTE: leave as POST to allow large amounts of data transfer
    post   'contacts/other',          to: 'contacts#get_other_contacts'         # NOTE: leave as POST to allow large amounts of data transfer
    post   'contacts/invite',         to: 'contacts#invite_contact'
  end
end
