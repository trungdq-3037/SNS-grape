class PostEntity < Grape::Entity
  expose :id
  expose :text
  expose :comments, using: CommentEntity
  expose :user, using: UserEntity
end
