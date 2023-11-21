class CommentEntity < Grape::Entity
  expose :id
  expose :comment_text
  expose :post_id
  expose :user, using: UserEntity
end
