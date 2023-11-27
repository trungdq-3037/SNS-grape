require 'rails_helper'
SECRET_KEY = ENV.fetch('SECRET_KEY', nil)
describe PostApi, type: :request do
  describe 'PostApi Text' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password', username: 'test') }
    let(:auth_headers) do
      token = JWT.encode({ id: user.id, username: user.username }, SECRET_KEY)
      { 'Authorization' => "Bearer #{token}" }
    end

    context 'Create post' do
      before do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'password' }
        @auth_token = JSON.parse(response.body)['token']
      end

      it 'Create successfully' do
        post '/api/v1/post/', headers: auth_headers, params: { text: 'Create a post' }
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse response.body
        expect(parsed_response['id']).to be_a(Integer)
        expect(parsed_response['text']).to eq('Create a post')
        expect(parsed_response['comments']).to be_a(Array)
        expect(parsed_response.dig('user', 'email')).to eq('test@example.com')
        expect(parsed_response.dig('user', 'username')).to eq('test')
      end

      it 'Missing field' do
        post '/api/v1/post/', headers: auth_headers
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('text is missing')
      end
    end

    context 'Edit post' do
      before do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'password' }
        @auth_token = JSON.parse(response.body)['token']
        user1 = User.find_by(email: 'test@example.com')
        user2 = User.create(email: 'test2@example.com', password: 'password', username: 'test')
        @post1 = Post.create(user_id: user1.id, text: 'post1')
        @post2 = Post.create(user_id: user2.id, text: 'post2')
      end

      it 'Missing field' do
        put "/api/v1/post/#{@post1.id}", headers: auth_headers
        expect(response).to have_http_status(:bad_request)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('text is missing')
      end

      it 'Edit owning Post' do
        put "/api/v1/post/#{@post1.id}", headers: auth_headers, params: { text: 'post' }
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse response.body
        expect(parsed_response['text']).to eq('post')
      end

      it 'Edit not own post' do
        put "/api/v1/post/#{@post2.id}", headers: auth_headers, params: { text: 'test' }
        expect(response).to have_http_status(:forbidden)
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq('You do not own this post')
      end
    end

    context 'Get all post' do
      before do
        post '/api/v1/login', params: { email: 'test@example.com', password: 'password' }
        @auth_token = JSON.parse(response.body)['token']
        user1 = User.find_by(email: 'test@example.com')
        @post1 = Post.create(user_id: user1.id, text: 'post1')
        @post2 = Post.create(user_id: user1.id, text: 'post2')
      end

      it 'All post' do
        get "/api/v1/post", headers: auth_headers
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse response.body
        expect(parsed_response).to be_a(Array)
        expect(parsed_response[0]['text']).to eq("post2")
      end
    end
  end
end
