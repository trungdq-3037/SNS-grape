class CommentApi < ApiV1
  helpers do
    def set_comment
      @comment = Comment.find(params[:id])
    rescue StandardError => e
      error!(e.message, 400)
    end

    def own_comment
      error!('Not own this post', 400) unless @current_user.id == @comment.user_id
    end
  end

  before do
    authenticated
  end

  resources :comment do
    desc 'Create a comment'
    params do
      requires :comment_text, type: String, desc: 'Comment content '
      requires :post_id, type: Integer, desc: 'Post id'
    end
    post do
      @comment = Comment.new({ comment_text: params[:comment_text], post_id: params[:post_id], user_id: @current_user.id })
      if @comment.save
        response_in_success @comment, CommentEntity, :ok
      else
        response_in_failure @comment.errors.full_messages, :bad_request
      end
    end

    desc 'Udpate comments'
    params do
      requires :comment_text, type: String, desc: 'Comment content '
      requires :id, type: Integer, desc: 'Comment id'
    end
    put ':id' do
      set_comment
      own_comment
      if @comment.update(comment_text: params[:comment_text])
        response_in_success @comment, CommentEntity, :ok
      else
        response_in_failure @comment.errors.full_messages, :bad_request
      end
    end

    desc 'Delete a comment'
    params do
      requires :id, type: Integer, desc: 'Comment id'
    end
    delete ':id' do
      set_comment
      own_comment
      if @comment.delete
        response_in_success @comment, CommentEntity, :ok
      else
        response_in_failure @comment.errors.full_messages, :bad_request
      end
    end
  end
end
