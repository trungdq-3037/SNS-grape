class ApiV1 < Grape::API
  version 'v1', using: :path
  format :json
  prefix :api
  helpers Authentication
  mount AuthenApi
  mount UserApi

end
