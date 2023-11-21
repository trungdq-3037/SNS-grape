class UserApi < ApiV1
  before do
    authenticated
  end

  resources :user do
    desc 'Get current user'
    get '/current' do
      response_in_success @current_user, UserEntity, :ok
    end

    desc 'Edit user information'
    params do
      requires :password, type: String
      requires :password_confirmation, type: String
      requires :username, type: String
    end
    put do
      @current_user.update({
                             username: params[:username],
                             password_confirmation: params[:password_confirmation],
                             password: params[:password]
                           })
      response_in_success @current_user, UserEntity, :ok
    rescue StandardError => e
      response_in_failure e, :internal_server_error
    end
  end
end
