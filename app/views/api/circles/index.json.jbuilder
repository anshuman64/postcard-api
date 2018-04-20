json.array! @circles do |circle|
  json.(circle, :id, :creator_id, :name, :created_at, :updated_at)

  json.user_ids circle.circling_users.ids
  json.group_ids circle.circling_groups.ids
end
