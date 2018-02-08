require 'pusher'

Pusher.app_id = '468835'
Pusher.key = ENV["PUSHER_KEY"]
Pusher.secret = ENV["PUSHER_SECRET"]
Pusher.cluster = 'us2'
Pusher.logger = Rails.logger
Pusher.encrypted = true
