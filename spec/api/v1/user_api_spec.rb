require 'rails_helper'
SECRET_KEY = ENV.fetch('SECRET_KEY', nil)
describe UserApi, type: :request do
  describe 'User api test' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password', username: 'test') }
    let(:auth_headers) do
      token = JWT.encode({ id: user.id, username: user.username }, SECRET_KEY)
      { 'Authorization' => "Bearer #{token}" }
    end

    context 'Get current user info with header token' do
      before do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'password' }
        @auth_token = JSON.parse(response.body)['token']
      end

      it 'With header token' do
        get '/api/v1/user/current', headers: auth_headers
        expect(response.status).to eq(200)
        parsed_response = JSON.parse response.body
        expect(parsed_response['email']).to eq('test@example.com')
        expect(parsed_response['username']).to eq('test')
      end

      it 'Without header token' do
        get '/api/v1/user/current'
        expect(response.status).to eq(401)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('Unauthorized')
      end
    end

    context 'Edit user info' do
      before do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'password' }
        @auth_token = JSON.parse(response.body)['token']
      end

      it 'Edit without username field' do
        put '/api/v1/user', params: { password: 'password', password_confirmation: 'password' }, headers: auth_headers
        expect(response.status).to eq(400)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('username is missing')
      end

      it 'Edit without password field' do
        put '/api/v1/user', params: { password_confirmation: 'password', username: 'test' }, headers: auth_headers
        expect(response.status).to eq(400)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('password is missing')
      end

      it 'Edit without password_confirmation field' do
        put '/api/v1/user', params: { password: 'password', username: 'test' }, headers: auth_headers
        expect(response.status).to eq(401)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('password_confirmation is missing')
      end

      it 'Without field' do
        put '/api/v1/user', headers: auth_headers
        expect(response.status).to eq(400)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('password is missing, password_confirmation is missing, username is missing')
      end
    end
  end
end
