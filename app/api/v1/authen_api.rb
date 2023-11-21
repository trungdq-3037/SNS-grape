class AuthenApi < ApiV1
  SECRET_KEY = ENV.fetch('SECRET_KEY', nil)

  desc 'login'
  params do
    requires :email, type: String, desc: 'Email address', message: 'Email address is required'
    requires :password, type: String, desc: 'password address', message: 'password is required'
  end
  post 'login' do
    @user = User.find_by email: params[:email]
    if @user.present? && @user.authenticate(params[:password])
      token = JWT.encode({ id: @user.id, username: @user.username }, SECRET_KEY)
      res = {
        token: token
      }
      status :ok
      present res
    else
      msg = {
        message: 'Invalid password or email'
      }
      response_in_failure msg, :bad_request
    end
  end

  desc 'Create new user'
  params do
    requires :email, type: String, desc: 'Email address', message: 'Email address is required'
    requires :password, type: String, desc: 'password address', message: 'password is required'
    requires :password_confirmation, type: String, desc: 'Password confirmation', message: 'Password confirmation is required'
    requires :username, type: String, desc: 'Username ', message: 'Username is required'
  end
  post 'register' do
    @user = User.new({
                       email: params[:email],
                       password: params[:password],
                       password_confirmation: params[:password_confirmation],
                       username: params[:username]
                     })
    if @user.save
      response_in_success @user, AuthenEntity, :ok
    else
      response_in_failure @user.errors.full_messages, :internal_server_error
    end
  end

  private

  def login_params
    params.permit(:email, :password)
  end

  def user_create_params
    params.permit(:email, :password, :password_confirmation, :username)
  end
end
