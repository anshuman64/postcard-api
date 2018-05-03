class ConvertImageUrlsToMedia < ActiveRecord::Migration[5.1]
  def change
    Post.where('image_url IS NOT NULL').each do |post|
      medium = Medium.new({ aws_path: post[:image_url], mime_type: 'image/jpeg', height: 500, width: 500, owner_id: post[:author_id], post_id: post.id })
      medium.save

      next
    end

    Message.where('image_url IS NOT NULL').each do |message|
      medium = Medium.new({ aws_path: message[:image_url], mime_type: 'image/jpeg', height: 500, width: 500, owner_id: message[:author_id], message_id: message.id })
      medium.save

      next
    end

    User.where('avatar_url IS NOT NULL').each do |user|
      medium = Medium.new({ aws_path: user[:avatar_url], mime_type: 'image/jpeg', height: 500, width: 500, owner_id: user.id })
      medium.save

      user.update({ avatar_medium_id: medium.id })

      next
    end

  end
end
