module Authentication
  SECRET_KEY = ENV.fetch('SECRET_KEY', nil)
  def authenticated
    return un_authorized_res if auth_token.blank?

    decoded = JWT.decode auth_token, SECRET_KEY
    @current_user = User.find(decoded[0]['id'])
    un_authorized_res if @current_user.nil?
  rescue StandardError
    un_authorized_res
  end

  def auth_token
    @auth_token ||= request.headers.fetch('authorization', '').split(' ').last
  end

  def un_authorized_res
    error!('Unauthorized', 401)
  end
end
