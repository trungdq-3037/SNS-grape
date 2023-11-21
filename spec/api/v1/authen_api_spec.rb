require 'rails_helper'
describe AuthenApi, type: :request do
  describe 'POST api/v1/register' do
    it 'register' do
      post '/api/v1/register', params: { username: 'abc', email: 'trung1@gmail.com', password: '123123', password_confirmation: '123123' }
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['email']).to eq('trung1@gmail.com')
      expect(body['username']).to eq('abc')
    end
  end

  describe 'POST api/v1/login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password', username: 'test') }

    context 'with valid credentials' do
      it 'logs in the user' do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'password' }
        expect(response.status).to eq(200)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['token']).to be_a(String)
      end
    end

    context 'with invalid credentials' do
      it 'returns an error message' do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'wrong_password' }
        expect(response.status).to eq(400)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['message']).to eq("Invalid password or email")
      end
    end
  end
  # describe 'GET api/v1/login' do
  #   it 'Return token' do
  #     create_list(:user, 3) # Assuming you're using FactoryBot for creating test data

  #     get '/v1/users'

  #     expect(response.status).to eq(200)
  #     expect(json_response.length).to eq(3)
  #   end
  # end

  # describe 'GET /v1/users/:id' do
  #   let(:user) { create(:user) } # Assuming you're using FactoryBot for creating test data

  #   it 'returns a specific user by ID' do
  #     get "/v1/users/#{user.id}"

  #     expect(response.status).to eq(200)
  #     expect(json_response['id']).to eq(user.id)
  #   end
  # end
end
