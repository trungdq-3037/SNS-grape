class PostApi < ApiV1
  before do
    authenticated
  end
  helpers do
    def set_post
      @post = Post.find params[:id]
    rescue StandardError => e
      error!(e.message, 400)
    end

    def own_post!(post)
      error!('You do not own this post', 403) unless @current_user.id == post.user_id
    end
  end

  resources :post do
    desc 'Get all posts'
    get do
      @posts = Post.eager_load(:comments, :user).order(created_at: :desc)
      response_in_success @posts, PostEntity, :ok
    end
    desc 'Create a new post'
    params do
      requires :text, type: String, desc: 'Post content'
    end
    post do
      @post = Post.new(user_id: @current_user.id, text: params[:text])
      if @post.save
        response_in_success @post, PostEntity, :ok
      else
        response_in_failure @post.errors.full_messages, :bad_request
      end
    end

    desc 'Edit a post'
    params do
      requires :id, type: String, desc: 'Id of the post'
      requires :text, type: String, desc: 'Post content'
    end
    put ':id' do
      set_post
      own_post! @post
      if @post.update(text: params[:text])
        response_in_success @post, PostEntity, :ok
      else
        response_in_failure @post.errors.full_messages, :bad_request
      end
    end
  end
end
